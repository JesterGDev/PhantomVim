-- Persona 5 UI polish on top of the phantom-thieves colorscheme:
-- statusline, cmdline/messages, buffer tabs, all sharp red-on-black.

local p5 = require("config.p5")

p5.highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    require("config.p5").highlights()
  end,
})

return {
  -- P5 statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local icons = LazyVim.config.icons

      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        theme = p5.statusline_theme(),
        globalstatus = true,
        section_separators = { left = "▌", right = "▐" },
        component_separators = { left = "▸", right = "◂" },
      })

      opts.sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          LazyVim.lualine.root_dir(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path() },
        },
        lualine_x = {
          Snacks.profiler.status(),
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          {
            "PHANTOM · THIEVES",
            color = { fg = p5.c.dark, bg = p5.c.gold, gui = "bold" },
          },
          {
            function()
              return "󰅐 " .. os.date("%H:%M")
            end,
            color = { fg = p5.c.fg, bg = p5.c.bg },
          },
        },
      }
      opts.extensions = { "neo-tree", "lazy", "fzf" }
      return opts
    end,
  },

  -- P5 cmdline + message panels
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.view = opts.cmdline.view or "cmdline_popup"
      opts.cmdline.opts = vim.tbl_deep_extend("force", opts.cmdline.opts or {}, {
        border = { style = "double" },
        win_options = {
          winhighlight = "NormalFloat:NoiceCmdlinePopup,FloatBorder:NoiceCmdlinePopupBorder,FloatTitle:NoiceCmdlinePopupTitle",
        },
      })
      opts.messages = opts.messages or {}
      opts.messages.opts = vim.tbl_deep_extend("force", opts.messages.opts or {}, {
        border = { style = "double" },
      })
      opts.popupmenu = opts.popupmenu or {}
      opts.popupmenu.opts = vim.tbl_deep_extend("force", opts.popupmenu.opts or {}, {
        border = { style = "double" },
      })
      opts.lsp = opts.lsp or {}
      opts.lsp.progress = { enabled = false }
      return opts
    end,
  },

  -- hard-edged Persona tabs
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.always_show_bufferline = true
      opts.options.separator_style = "slant"
      opts.options.indicator = { style = "icon", icon = "▮" }
      opts.options.offsets = {
        {
          filetype = "neo-tree",
          text = "EXPLORER",
          highlight = "Directory",
          text_align = "left",
        },
        {
          filetype = "snacks_layout_box",
        },
      }
      return opts
    end,
  },
}