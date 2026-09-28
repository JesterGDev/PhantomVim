# PhantomVim

A Persona 5–inspired, Cursor-style **Neovim IDE distribution** built on [LazyVim](https://www.lazyvim.org).

```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
PHANTOM·THIEVES // CODING LEAP
GIMME YOUR CODE
▸ <space> e      EXPLORER
▸ <space> oa     OPENCODE AI
▸ <space> oq     ASK OPENCODE
▸ <space> os     OPENCODE ACTIONS
▸ <space> ot     TERMINAL
▸ <space> aa     AVANTE
▸ <space> ac     AVANTE CHAT
▸ <space> am     SELECT MODEL
▸ <space> ol     REASSEMBLE LAYOUT
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

Sharp red-on-black, hard edges, all-out attack — PhantomVim turns your editor into an
"Employee" workstation: **files on the left, code in the middle, AI on the right,
terminal at the bottom.**

## Features

- **Employee-style layout** — file explorer (neo-tree) left, editor center, opencode AI panel right, terminal bottom. Reassemble it any time with `<space>ol`.
- **Built-in AI** — the right panel runs the real [opencode](https://opencode.ai) TUI docked inside Vim, wired to your editor via [opencode.nvim](https://github.com/nickjvandyke/opencode.nvim): prompts carry your buffer/selection context, and edits come back as accept/reject `:diffpatch`. Ships with opencode's free cloud models — **no accounts, no API keys, no login**.
- **Phantom Thieves theme** — a full `phantom-thieves` colorscheme, P5-laced lualine statusline, bufferline tabs, and double-bordered noice command palette.
- **avante.nvim** — optional chat/inline-edit sidekick with native Rust core (`<space>aa`, `<space>ac`, `<space>ae`, ...).
- Everything else LazyVim gives you: fuzzy finder, LSP, git integration, sessions, 100+ prepackaged plugins.

## Requirements

- Neovim **>= 0.11** (tested on 0.12)
- `git`, and a [Nerd Font](https://www.nerdfonts.com/) in your terminal for icons (LazyVim standard)
- **Optional:** the `opencode` CLI on your `PATH` for the AI panel

## Install

> Backup/remove any existing `~/.config/nvim` first, then:

```bash
git clone https://github.com/JesterGDev/PhantomVim.git ~/.config/nvim
nvim
```

On first launch LazyVim installs all plugins automatically. Changes are picked up on
restart (or with `<space>pr` → `Lazy reload`).

### Upgrade

```bash
nvim --headless "+Lazy! update" +qa
```

## AI setup (`<space>oa`)

The right panel is the opencode TUI, connected to nvim as an editor-aware server
(opencode.nvim talks to it on `127.0.0.1:34829`). Free models are available immediately —
no setup:

- `opencode/big-pickle` (flagship, default)
- `opencode/ling-3.0-flash-fin-free`, `opencode/nemotron-*`, and more — switch in the panel's model list

Optional, for stronger models: `opencode auth login` once and pick a provider.

### Editor-aware commands

- `<space>oa` — open/close the AI panel
- `<space>oq` — ask opencode with the current buffer/selection as context (`@this`)
- `<space>os` — pick an action via the fuzzy picker (`<a-o>` sends the selection to opencode)
- `go<movement>` (visual/normal, e.g. `goip`) — send the covered text range to opencode
- `goo` — send the current line
- `<S-C-u>` / `<S-C-d>` — scroll the AI session up/down
- Accepts/rejects model edits through nvim's built-in `:diffpatch` flow

### avante (optional second AI)

avante uses **its own** provider, not opencode's free tier:

- `ANTHROPIC_API_KEY` in your shell → Claude
- `OPENAI_API_KEY` → GPT
- Local: `ollama` running with `qwen3-coder` pulled

If `cargo` is installed, `:Lazy sync` also builds avante's native Rust core
(tokenizers, html2md, repo-map). Without it, avante still works in pure-Lua mode.

## Keymaps

| Keys | What it does |
|---|---|
| `<space>oa` | AI panel (opencode) |
| `<space>oq` | Ask opencode (buffer/selection context) |
| `<space>os` | Pick an opencode action |
| `go` / `goo` | Send range / line to opencode |
| `<space>ot` | Bottom terminal |
| `<space>e` | File explorer |
| `<space>ol` | Rebuild the IDE layout |
| `<space>ff` | Find files (fuzzy) |
| `<space>fr` | Recent files |
| `<space>fb` | Open buffers |
| `<space>fw` | Grep word under cursor |
| `]b` / `[b` | Next / prev buffer |
| `<space>ca` | LSP code action |
| `gd` | Go to definition |
| `K` | Hover docs |
| `<space>gs` | Git status |
| `<space>gg` | LazyGit |
| `<space>aa/ac/ae/am/at` | Avante: ask / chat / edit / model / toggle |

Press `<space>` and pause — LazyVim's which-key menu lists everything.

## Project structure

```
~/.config/nvim/
├── lazyvim.json          # LazyVim extras (neo-tree, edgy, avante)
├── colors/
│   └── phantom-thieves.lua  # the theme
└── lua/
    ├── config/p5.lua     # shared P5 palette + highlight helpers
    └── plugins/
        ├── ai.lua        # opencode panel + editor-aware opencode.nvim + avante
        ├── layout.lua    # explorer/terminal/layout assembly
        ├── persona5.lua  # lualine / noice / bufferline polish
        └── theme.lua     # colorscheme selection
```

## Credits

- Built on the excellent [LazyVim](https://www.lazyvim.org) starter.
- Persona 5 is a trademark of Atlus. This is an unofficial, fan-made color/furniture
  theme with no affiliation to, or endorsement by, Atlus / SEGA.

## License

[MIT](./LICENSE)