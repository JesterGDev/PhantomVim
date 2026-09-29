# PhantomVim

A Persona 5–inspired, Cursor-style **Neovim IDE distribution** built on [LazyVim](https://www.lazyvim.org).

```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
PHANTOM·THIEVES // CODING LEAP
GIMME YOUR CODE
▸ ,e / <a-h>  EXPLORER           ▸ ,os  OPENCODE ACTIONS
▸ ,oa / <f4>  OPENCODE AI        ▸ ,ot / <f3>  TERMINAL CONTROLLER
▸ ,oq         ASK OPENCODE       ▸ ,ol  REASSEMBLE LAYOUT
▸ ,, / <f1>   KEYBINDING GUIDE   ▸ <a-l> AI   <a-j> EDITOR   <a-k> GUIDE
▸ ,aa / ,ac   AVANTE CHAT        ▸ n <file> / nvim <file>  OPEN IN EDITOR
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

Sharp red-on-black, hard edges, all-out attack — PhantomVim turns your editor into an
"Employee" workstation: **files on the left, code in the middle, AI on the right,
terminal at the bottom.**

## PhantomVim is terminal-first

The **bottom terminal is the controller**. Whatever directory you `cd` into there is
instantly followed by the file explorer and the AI panel; open a file from the shell
with `n <file>` (or `nvim <file>`) and it opens in the editor above, with its path in
the window's title bar. Works entirely in one hand on the keyboard — no mouse.

## Features

- **Terminal-first, mouseless** — the bottom terminal drives everything: `cd` anywhere and the explorer + AI follow; `n <file>` / `nvim <file>` opens files in the editor above (`~/.config/nvim/lua/config/phantom.lua`).
- **Employee-style layout** — file explorer (neo-tree) left, editor center, opencode AI panel right, terminal bottom. Reassemble it any time with `,ol`.
- **On-screen keybinding Guide** — no messy start-screen: fresh sessions show a living PhantomVim Guide (`F1` / `,,`) that lists every zone shortcut, terminal commands and a live dump of all your keymaps. It returns automatically whenever all buffers are closed.
- **No Space bar hostage** — the leader is `,`, so you never fight LazyVim's `<space>` prefixes while typing; quick zone jumps are one key: `<F1>` guide, `<F2>` explorer, `<F3>` terminal, `<F4>` AI.
- **Built-in AI** — the right panel runs the real [opencode](https://opencode.ai) TUI docked inside Vim, wired to your editor via [opencode.nvim](https://github.com/nickjvandyke/opencode.nvim): prompts carry your buffer/selection context, and edits come back as accept/reject `:diffpatch`. Ships with opencode's free cloud models — **no accounts, no API keys, no login**.
- **Phantom Thieves theme** — a full `phantom-thieves` colorscheme, P5-laced lualine statusline, bufferline tabs, and double-bordered noice command palette.
- **avante.nvim** — optional chat/inline-edit sidekick with native Rust core (`,aa`, `,ac`, `,ae`, ...).
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

## AI setup (`,oa`)

The right panel is the opencode TUI, connected to nvim as an editor-aware server
(opencode.nvim talks to it on `127.0.0.1:34829`). Free models are available immediately —
no setup:

- `opencode/big-pickle` (flagship, default)
- `opencode/ling-3.0-flash-fin-free`, `opencode/nemotron-*`, and more — switch in the panel's model list

Optional, for stronger models: `opencode auth login` once and pick a provider.

### Editor-aware commands

- `,oa` — open/close the AI panel
- `,oq` — ask opencode with the current buffer/selection as context (`@this`)
- `,os` — pick an action via the fuzzy picker (`<a-o>` sends the selection to opencode)
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

## Using the terminal controller

The bottom terminal is the control room:

- `cd <dir>` — the explorer reroots to that dir and the AI panel starts following it
- `n <file>` — open the file in the editor above (takes multiple files; `n -` follows with `open.txt`)
- `nvim <file>` / `vim <file>` / `vi <file>` — same, opened in the editor (never nested)
- any other shell command works as usual (`git`, `ls`, `rg`, ...)

The editor window's title bar always shows the current file's path.

## Zones: one key to every pane

| Zone | Keys |
|---|---|
| Guide | `<F1>`, `,,` |
| Explorer | `<F2>`, `,e`, `<a-h>` |
| Editor | `<a-j>` |
| Terminal controller | `<F3>`, `,ot`, `<a-k>` |
| AI panel | `<F4>`, `,oa`, `<a-l>` |

Resize panes with `<a-↑>/<a-↓>/<a-←>/<a-→>`.

## Keymaps

| Keys | What it does |
|---|---|
| `,oa` | AI panel (opencode) |
| `,oq` | Ask opencode (buffer/selection context) |
| `,os` | Pick an opencode action |
| `go` / `goo` | Send range / line to opencode |
| `,ot` | Bottom terminal controller |
| `,e` | File explorer |
| `,ol` | Rebuild the IDE layout |
| `,,` / `<F1>` | PhantomVim keybinding Guide |
| `<F2>` / `<F3>` / `<F4>` | Explorer / terminal / AI |
| `<a-hjkl>` | Jump between explorer / editor / terminal / AI |
| `,ff` | Find files (fuzzy) |
| `,fr` | Recent files |
| `,fb` | Open buffers |
| `,fw` | Grep word under cursor |
| `]b` / `[b` | Next / prev buffer |
| `,ca` | LSP code action |
| `gd` | Go to definition |
| `K` | Hover docs |
| `,gs` | Git status |
| `,gg` | LazyGit |
| `,aa/ac/ae/am/at` | Avante: ask / chat / edit / model / toggle |

Press `F1` any time for the full, live keymap guide. Because the leader is `,`, all
LazyVim `<space>...` shortcuts move to `,...`.

## Project structure

```
~/.config/nvim/
├── lazyvim.json          # LazyVim extras (neo-tree, edgy, avante)
├── colors/
│   └── phantom-thieves.lua  # the theme
└── lua/
    ├── config/
    │   ├── p5.lua            # shared P5 palette + highlight helpers
    │   └── phantom.lua       # sync engine: terminal→explorer/AI, open-in-editor, guide, zones
    └── plugins/
        ├── ai.lua        # opencode panel + editor-aware opencode.nvim + avante
        ├── layout.lua    # explorer/terminal/layout assembly + controller wiring
        ├── persona5.lua  # lualine / noice / bufferline polish
        └── theme.lua     # colorscheme selection
```

## Credits

- Built on the excellent [LazyVim](https://www.lazyvim.org) starter.
- Persona 5 is a trademark of Atlus. This is an unofficial, fan-made color/furniture
  theme with no affiliation to, or endorsement by, Atlus / SEGA.

## License

[MIT](./LICENSE)