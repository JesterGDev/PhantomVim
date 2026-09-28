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

local function opencode_toggle()
  local bin = vim.fn.exepath("opencode")
  if bin == "" then
    require("snacks").notify.warn("opencode CLI not found on PATH")
    return
  end
  require("snacks").terminal.toggle(bin, {
    cwd = LazyVim.root(),
    env = { TERM = "xterm-256color" },
    win = {
      position = "right",
      width = 0.42,
      relative = "editor",
      wo = { winbar = "%#P5Title# OPENCODE %#P5TitleBar#│ REPLICATING HEARTS %*" },
    },
  })
end

return {
  { import = "lazyvim.plugins.extras.ai.avante" },

  -- opencode lives on the right side of the editor
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>oa", opencode_toggle, desc = "OpenCode AI (right panel)" },
    },
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