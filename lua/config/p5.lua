local M = {}

M.c = {
  bg = "#0a0a0a",
  dark = "#050505",
  light = "#1b1b1b",
  fg = "#f2f2f2",
  dim = "#5c5c5c",
  lfg = "#cfcfcf",
  red = "#e60012",
  bred = "#ff4a52",
  pink = "#ff5c8a",
  gold = "#ffc72c",
  cyan = "#4ec9c9",
  blue = "#5f72d8",
  green = "#6fbf6b",
  orange = "#ff7a1a",
  brown = "#9c6b52",
  sel = "#2b0a0e",
}

function M.highlights()
  local hl, c = vim.api.nvim_set_hl, M.c

  -- window titles (winbar / panel headers)
  hl(0, "P5Title", { fg = c.dark, bg = c.red, bold = true })
  hl(0, "P5TitleGold", { fg = c.dark, bg = c.gold, bold = true })
  hl(0, "P5TitleBar", { fg = c.lfg, bg = c.dark })

  -- startup banner
  hl(0, "P5BannerTitle", { fg = c.bred, bold = true })
  hl(0, "P5BannerGold", { fg = c.gold, bold = true })
  hl(0, "P5BannerDim", { fg = c.dim })
  hl(0, "P5BannerArrow", { fg = c.pink })

  -- lualine mode blocks
  hl(0, "ModeNormal", { fg = c.dark, bg = c.red, bold = true })
  hl(0, "ModeInsert", { fg = c.dark, bg = c.gold, bold = true })
  hl(0, "ModeVisual", { fg = c.dark, bg = c.pink, bold = true })
  hl(0, "ModeReplace", { fg = c.dark, bg = c.orange, bold = true })
  hl(0, "ModeCommand", { fg = c.dark, bg = c.cyan, bold = true })
  hl(0, "ModeTerminal", { fg = c.dark, bg = c.blue, bold = true })

  -- bufferline persona
  hl(0, "BufferLineFill", { bg = c.dark })
  hl(0, "BufferLineBuffer", { fg = c.dim, bg = c.dark })
  hl(0, "BufferLineBufferVisible", { fg = c.lfg, bg = c.dark })
  hl(0, "BufferLineBufferSelected", { fg = c.bred, bg = c.bg, bold = true })
  hl(0, "BufferLineIndicatorSelected", { fg = c.red })
  hl(0, "BufferLineIndicatorVisible", { fg = c.dim })
  hl(0, "BufferLineIndicator", { fg = c.dim })
  hl(0, "BufferLineSeparatorSelected", { fg = c.red })
  hl(0, "BufferLineSeparator", { fg = c.dark })
  hl(0, "BufferLineTabSelected", { fg = c.bred, bg = c.light })
  hl(0, "BufferLineDuplicateSelected", { fg = c.bred })
  hl(0, "BufferLineCloseButton", { fg = c.dim })
  hl(0, "BufferLineCloseButtonSelected", { fg = c.bred })
  hl(0, "BufferLineErrorSelected", { fg = c.red })
  hl(0, "BufferLineWarningSelected", { fg = c.gold })
  hl(0, "BufferLineInfoSelected", { fg = c.cyan })
  hl(0, "BufferLineHintSelected", { fg = c.lfg })

  -- noice panels
  hl(0, "NoiceCmdlinePopup", { fg = c.lfg, bg = c.light })
  hl(0, "NoiceCmdlinePopupTitle", { fg = c.red, bold = true })
  hl(0, "NoiceCmdlinePopupBorder", { fg = c.red, bg = c.light })
  hl(0, "NoiceCmdlineIcon", { fg = c.red })
  hl(0, "NoicePopupBorder", { fg = c.red, bg = c.light })
  hl(0, "NoicePopupTitle", { fg = c.red, bold = true })
  hl(0, "NoiceConfirmBorder", { fg = c.gold, bg = c.light })
end

function M.statusline_theme()
  local c = M.c
  local function mk(mode_color)
    return {
      a = { fg = c.dark, bg = mode_color, gui = "bold" },
      b = { fg = c.lfg, bg = c.light },
      c = { fg = c.lfg, bg = c.dark },
      x = { fg = c.lfg, bg = c.light },
      y = { fg = c.dim, bg = c.bg },
      z = { fg = c.dark, bg = c.gold, gui = "bold" },
    }
  end
  return {
    normal = mk(c.red),
    insert = mk(c.gold),
    visual = mk(c.pink),
    replace = mk(c.orange),
    command = mk(c.cyan),
    terminal = mk(c.blue),
    inactive = {
      a = { fg = c.dim, bg = c.dark },
      b = { fg = c.dim, bg = c.dark },
      c = { fg = c.dim, bg = c.dark },
      x = { fg = c.dim, bg = c.dark },
      y = { fg = c.dim, bg = c.dark },
      z = { fg = c.dim, bg = c.dark },
    },
  }
end

---Paints a buffer with P5-styled lines.
---@param buf number
---@param lines table<string,string> list of {text, hl} pairs
function M.paint_banner(buf, lines)
  local texts = vim.iter(lines):map(function(l)
    return l.text
  end):totable()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, texts)
  vim.bo[buf].modifiable = false
  for i, l in ipairs(lines) do
    if l.hl then
      vim.api.nvim_buf_add_highlight(buf, -1, l.hl, i - 1, 0, -1)
    end
  end
end

return M