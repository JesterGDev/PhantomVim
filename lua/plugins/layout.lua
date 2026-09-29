-- PhantomVim IDE layout: file explorer (left) + code (center) + AI (right).
-- The BOTTOM terminal is the controller (see lua/config/phantom.lua): the
-- explorer and the AI panel follow its PWD, and `n <file>` / `nvim <file>`
-- open in the editor above instead of nesting a second editor.

local p5 = require("config.p5")
local phantom = require("config.phantom")

local restored = false
local laid_out = false

vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = function()
    restored = true
  end,
})

local function open_tree()
  local ok, neo = pcall(require, "neo-tree.command")
  if ok then
    neo.execute({
      action = "show",
      source = "filesystem",
      position = "left",
      dir = vim.uv.cwd(),
    })
  end
end

local function main_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local name = vim.api.nvim_buf_get_name(0)
  local empty = #lines == 1 and lines[1] == ""
  if empty and name == "" and vim.bo.filetype == "" then
    return true
  end
  return false
end

local function started_fresh()
  local n = vim.fn.argc(-1)
  if n == 0 then
    return true
  end
  local ok, st = pcall(vim.uv.fs_stat, vim.fn.argv(0))
  return n == 1 and ok and st and st.type == "directory"
end

local function apply_ide_layout()
  if laid_out or restored then
    return
  end
  laid_out = true

  local main_win = vim.api.nvim_get_current_win()
  vim.schedule(function()
    pcall(open_tree)
    if started_fresh() then
      pcall(phantom.terminal_toggle)
    end
    -- the controller terminal gets the focus on a fresh start
    local fresh = started_fresh()
    if fresh then
      local term_wins = phantom.zone_windows("terminal")
      if #term_wins > 0 and vim.api.nvim_win_is_valid(term_wins[#term_wins]) then
        vim.api.nvim_set_current_win(term_wins[#term_wins])
      end
    else
      -- stick the code viewer in the middle
      if vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_set_current_win(main_win)
      end
    end
    if fresh and main_buffer() then
      phantom.show_guide()
    end
    -- every window renders its own P5 winbar (path / zone)
    vim.o.winbar = "%{%v:lua.require('config.phantom').winbar()%}"
  end)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    apply_ide_layout()
  end,
})

-- The plugins/ import is assembled lazily (after VimEnter / UIEnter), so the
-- sync engine, keymap layer and guide-recovery are scheduled straight from the
-- module scope. Everything here is idempotent, so it also runs under the
-- VeryLazy chain in a GUI without double-starting.
vim.schedule(function()
  phantom.setup_keymaps()
  phantom.start()
end)

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufEnter" }, {
  callback = function()
    vim.schedule(phantom.maybe_show_guide_on_empty)
  end,
})
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufEnter" }, {
  callback = function()
    vim.schedule(phantom.maybe_show_guide_on_empty)
  end,
})

return {
  -- file explorer pinned to the left edge, follows the controller's location
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
        position = "left",
        width = 34,
      })
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        follow_current_file = { enabled = true, leave_dirs_open = false },
        use_libuv_file_watcher = true,
      })
    end,
  },

  -- snacks powers the panes; the stock LazyVim dashboard is replaced by the
  -- PhantomVim Guide as the default screen, so disable it here.
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ot",
        phantom.terminal_toggle,
        desc = "Terminal (controller, bottom)",
      },
      { "<leader>ol", apply_ide_layout, desc = "Reassemble IDE layout" },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.dashboard = vim.tbl_deep_extend("force", opts.dashboard or {}, { enabled = false })
      return opts
    end,
  },
}