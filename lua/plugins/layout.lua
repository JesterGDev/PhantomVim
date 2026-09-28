-- Cursor-style IDE layout: file explorer (left) + terminal (bottom) + code (center).
-- The opencode AI panel on the right is toggled with <leader>oa (see plugins/ai.lua).

local p5 = require("config.p5")

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

local function open_terminal()
  require("snacks").terminal.get(nil, {
    win = {
      position = "bottom",
      height = 0.28,
      relative = "editor",
      wo = { winbar = "%#P5TitleGold# TERMINAL %#P5TitleBar#│ ALL-OUT ATTACK READY %*" },
    },
  })
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

local function paint_splash()
  local lines = {
    { text = "", hl = nil },
    { text = "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓", hl = "P5BannerDim" },
    { text = "", hl = nil },
    { text = "PHANTOM·THIEVES // CODING LEAP", hl = "P5BannerTitle" },
    { text = "GIMME YOUR CODE", hl = "P5BannerGold" },
    { text = "", hl = nil },
    { text = "▸ <space> e      EXPLORER", hl = "P5BannerDim" },
    { text = "▸ <space> oa     OPENCODE AI", hl = "P5BannerDim" },
    { text = "▸ <space> ot     TERMINAL", hl = "P5BannerDim" },
    { text = "▸ <space> aa     AVANTE", hl = "P5BannerDim" },
    { text = "▸ <space> ac     AVANTE CHAT", hl = "P5BannerDim" },
    { text = "▸ <space> am     SELECT MODEL", hl = "P5BannerDim" },
    { text = "▸ <space> ol     REASSEMBLE LAYOUT", hl = "P5BannerDim" },
    { text = "", hl = nil },
    { text = "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓", hl = "P5BannerDim" },
  }
  p5.paint_banner(0, lines)
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
      pcall(open_terminal)
    end
    -- stick the code viewer in the middle
    if vim.api.nvim_win_is_valid(main_win) then
      vim.api.nvim_set_current_win(main_win)
    end
    if started_fresh() and main_buffer() then
      paint_splash()
    end
  end)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = apply_ide_layout,
})

return {
  -- file explorer pinned to the left edge
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
        position = "left",
        width = 34,
      })
    end,
  },

  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ot",
        function()
          require("snacks").terminal.toggle(nil, {
            win = {
              position = "bottom",
              height = 0.28,
              relative = "editor",
              wo = { winbar = "%#P5TitleGold# TERMINAL %#P5TitleBar#│ ALL-OUT ATTACK READY %*" },
            },
          })
        end,
        desc = "Terminal (bottom panel)",
      },
      { "<leader>ol", apply_ide_layout, desc = "Reassemble IDE layout" },
    },
  },
}