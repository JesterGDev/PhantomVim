-- Cursor-style AI layer: avante.nvim (chat + inline edits) merged with opencode
-- (the right-side panel runs the opencode TUI itself, so project-aware coding
-- agents work exactly like running `opencode` in a terminal).

local function detect_provider()
  if vim.env.ANTHROPIC_API_KEY and vim.env.ANTHROPIC_API_KEY ~= "" then
    return "claude"
  end
  if vim.env.OPENAI_API_KEY and vim.env.OPENAI_API_KEY ~= "" then
    return "openai"
  end
  return "ollama"
end

-- opencode chat panel: the real opencode TUI docked on the right. The Esc
-- fix keeps `Esc` inside opencode (the default snacks double-<Esc> mapping
-- steals focus mid-typing and throws the cursor out of the message box).
local function opencode_toggle()
  local bin = vim.fn.exepath("opencode")
  if bin == "" then
    require("snacks").notify.warn("opencode CLI not found on PATH")
    return
  end
  require("snacks").terminal.toggle({ bin, "--port", "34829" }, {
    cwd = LazyVim.root(),
    env = { TERM = "xterm-256color" },
    win = {
      position = "right",
      width = 0.42,
      relative = "editor",
      wo = { winbar = "%#P5Title# OPENCODE %#P5TitleBar#│ REPLICATING HEARTS %*" },
    },
  })
  vim.defer_fn(function()
    local ok, cur = pcall(vim.api.nvim_get_current_buf)
    if ok and vim.api.nvim_buf_get_name(cur):match("opencode") then
      pcall(vim.api.nvim_buf_del_keymap, cur, "t", "<Esc>")
    end
  end, 60)
end

return {
  { import = "lazyvim.plugins.extras.ai.avante" },

  -- opencode.nvim: makes opencode editor-aware INSIDE nvim. Chat prompts get
  -- buffer/selection context (@this, @buffer, ...), edits come back as nvim
  -- :diffpatch you accept/reject, and opencode can drive nvim via its MCP
  -- server (open files, jump to locations). The chat TUI still lives in the
  -- right panel; the plugin connects to it by URL.
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- pinned: our opencode CLI is v1 (main branch targets v2)
    dependencies = { "folke/snacks.nvim" },
    priority = 70,
    -- all keymaps are registered in config() below: lazy.nvim's `keys`
    -- retrofit resolves <leader> inconsistently, so we (a) load eagerly and
    -- (b) let nvim resolve <leader> at map time (mapleader is set to " ").
    opts = function()
      vim.g.opencode_opts = {
        server = {
          -- open the (already P5-styled) chat panel when a server is needed
          start = opencode_toggle,
          -- fixed port (avoids requiring `lsof` for process discovery); the
          -- toggle spawns `opencode --port 34829`, so the URL is known
          url = "http://127.0.0.1:34829",
        },
        -- ask()/select() are the "editor-aware" entry points: they read the
        -- current buffer/selection and hand it to a fresh opencode session.
        autostart = false,
      }
    end,
    config = function(_, opts)
      vim.g.opencode_opts = vim.tbl_deep_extend("force", vim.g.opencode_opts or {}, opts)
      vim.keymap.set("n", "<leader>oa", opencode_toggle, { desc = "OpenCode chat (right panel)" })
      vim.keymap.set("n", "<leader>oq", function()
        require("opencode").ask()
      end, { desc = "Ask OpenCode" })
      vim.keymap.set("n", "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select an OpenCode prompt/action" })
      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll OpenCode up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll OpenCode down" })
      -- editor-aware range/line operators: go{a} sends the motion range, goo sends the line
      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this")
      end, { expr = true, desc = "Send range to OpenCode" })
      vim.keymap.set({ "n" }, "goo", function()
        return require("opencode").operator("@this") .. "_"
      end, { expr = true, desc = "Send line to OpenCode" })
    end,
  },

  -- snacks integration: vim-native prompt input + action picker for opencode
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.input = opts.input or {}
      opts.picker = opts.picker or {}
      opts.picker.actions = vim.tbl_deep_extend("force", opts.picker.actions or {}, {
        opencode_send = function(picker)
          local items = vim.tbl_map(function(item)
            if item.file then
              return require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
            end
            return item.text
          end, picker:selected({ fallback = true }))
          require("opencode").prompt(table.concat(items, ", ") .. " ")
        end,
      })
      opts.picker.win = opts.picker.win or {}
      opts.picker.win.input = opts.picker.win.input or {}
      opts.picker.win.input.keys = vim.tbl_deep_extend("force", opts.picker.win.input.keys or {}, {
        ["<a-o>"] = { "opencode_send", mode = { "n", "i" } },
      })
      return opts
    end,
  },

  -- avante: docked right, P5-styled, provider auto-detected from env
  {
    "yetone/avante.nvim",
    -- mega.cmdparse is a pure-Lua library avante requires for its command
    -- parser; the rest of the native (Rust) core is optional (`make`).
    dependencies = { "ColinKennedy/mega.cmdparse", "ColinKennedy/mega.logging" },
    -- the native `make` build needs cargo; skip it silently when missing.
    build = function()
      if vim.fn.executable("cargo") == 1 then
        vim.fn.system("make -C " .. vim.fn.stdpath("data") .. "/lazy/avante.nvim")
      end
    end,
    opts = function(_, opts)
      opts.provider = detect_provider()

      opts.claude = vim.tbl_deep_extend("force", opts.claude or {}, {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-5",
        max_tokens = 32768,
      })
      opts.openai = vim.tbl_deep_extend("force", opts.openai or {}, {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-5",
      })
      opts.ollama = vim.tbl_deep_extend("force", opts.ollama or {}, {
        endpoint = "http://127.0.0.1:11434",
        model = "qwen3-coder",
        max_tokens = 8192,
      })

      opts.layout = {
        position = "right",
        width = 0.4,
        height = 0.96,
        vsplit = true,
      }

      opts.windows = vim.tbl_deep_extend("force", opts.windows or {}, {
        sidebar_header = { align = "center", rounded = false, title = "CHAT" },
        header = { align = "center", rounded = false },
      })

      opts.suggestions = {
        enabled = true,
        keymap = {
          accept_word = "<C-j>",
          accept_line = "<C-l>",
        },
      }

      return opts
    end,
  },
}