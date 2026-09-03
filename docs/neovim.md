# Neovim

The shared Neovim configuration is a focused code editor built on LazyVim. It
borrows the visual direction and useful workflows from Gentleman.Dots without
including its AI, Obsidian, WSL, or tmux integrations.

The source of truth lives in `shared/.config/nvim/` and is linked to
`~/.config/nvim/` by the `shared` GNU Stow package.

## Install

The shared Mise configuration provides Neovim, `ripgrep`, and `fd`. Install the
declared tools and link the dotfiles:

```bash
mise install
bash scripts/stow-shared.sh
```

On first launch, `lazy.nvim` installs the configured plugins and Mason installs
the required language tools. A Nerd Font is recommended so filetype and status
icons render correctly.

Open the current project with:

```bash
nvim .
```

## Configuration layout

```text
shared/.config/nvim/
├── init.lua
├── lazy-lock.json
├── lazyvim.json
└── lua/
    ├── config/
    │   ├── autocmds.lua
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   └── options.lua
    └── plugins/
        ├── explorers.lua
        ├── learning.lua
        └── ui.lua
```

- `lua/config/lazy.lua` defines the LazyVim extras and plugin loading policy.
- `lua/config/options.lua` contains editor-wide behavior.
- `lua/config/keymaps.lua` contains mappings not owned by a plugin.
- `lua/plugins/` contains small, purpose-specific plugin specifications.
- `lazy-lock.json` pins plugin revisions for reproducible installations.

## File explorers

The three explorers are intentional and serve different workflows.

| Explorer | Purpose | Shortcut |
| --- | --- | --- |
| Neo-tree | Persistent project-wide tree with Git and diagnostic context | `<Space>e` |
| Mini Files | Focused column view of the current directory and its hierarchy | `<Space>fm` |
| Oil | Edit filesystem entries as normal buffer lines | `-` |

Additional shortcuts:

| Shortcut | Action |
| --- | --- |
| `<Space>E` | Open Neo-tree at the current working directory |
| `<Space>fM` | Open Mini Files at the current working directory |
| `<Space>fo` | Open Oil in a floating window |

Use Neo-tree to understand the whole project, Mini Files when navigating a
deep or crowded directory, and Oil for efficient rename, move, create, and
delete operations. Neo-tree remains the default directory explorer; Mini Files
and Oil are opened explicitly.

## Search, navigation, and diagnostics

LazyVim provides Snacks Picker, Trouble, Todo Comments, Which Key, Lualine,
Noice, and Git signs. Useful defaults include:

| Shortcut | Action |
| --- | --- |
| `<Space><Space>` | Find files |
| `<Space>/` | Search project text |
| `<Space>fb` | Find open buffers |
| `<Space>xx` | Toggle project diagnostics in Trouble |
| `<Space>st` | Search TODO-style comments |
| `<Space>cs` | Toggle the code outline |
| `<C-h/j/k/l>` | Move between Neovim windows |
| `<C-s>` | Save the current file |

Press `<Space>` and pause to let Which Key show the available mappings and
their descriptions.

## Languages and formatting

The initial setup supports the languages already represented in these
dotfiles:

- JavaScript and TypeScript, with Biome as the primary formatter and linter.
- JSON, YAML, TOML, Markdown, Dockerfiles, and Tailwind CSS.
- Python, Go, and Ruby, including their maintained LazyVim integrations.

Blink provides completion, Treesitter provides syntax-aware editing, and Mason
manages editor-side language tools. Use the following interfaces to inspect
their state:

```vim
:Mason
:LspInfo
:ConformInfo
:checkhealth
```

Language support should be added as a LazyVim extra in
`lua/config/lazy.lua` when possible. This keeps LSP, formatting, linting, and
debugging behavior together instead of duplicating upstream configuration.

## Debugging

The debugging stack consists of `nvim-dap`, `nvim-dap-ui`, virtual text, and
language-specific adapters. Initial adapters cover JavaScript/TypeScript,
Python, Go, and Ruby. Existing `.vscode/launch.json` configurations are also
supported.

| Shortcut | Action |
| --- | --- |
| `<Space>db` | Toggle breakpoint |
| `<Space>dB` | Set conditional breakpoint |
| `<Space>dc` | Start or continue |
| `<Space>di` | Step into |
| `<Space>dO` | Step over |
| `<Space>do` | Step out |
| `<Space>du` | Toggle the debugger UI |
| `<Space>de` | Evaluate the selection or expression |
| `<Space>dr` | Toggle the debugger REPL |
| `<Space>dt` | Terminate the session |

DAP is a client, so adding another language requires both a debug adapter and
a launch/attach configuration. Prefer the corresponding LazyVim language extra
when it provides that integration.

## Learning Vim

Run the included movement practice game with:

```vim
:VimBeGood
```

Toggle Screenkey with `<Space>uk`. Screenkey displays the keys that were
pressed; it does not grade whether a command was correct. Together, Vim Be Good
provides repetition while Screenkey makes multi-key sequences visible.

Gentleman.Dots also ships a separate Vim Mastery Trainer. It is not included
here because it belongs to that project's installer rather than its Neovim
configuration. It can be evaluated later as a complementary structured course.

## Optional interface tools

| Shortcut or command | Purpose |
| --- | --- |
| `<Space>uz` | Toggle distraction-free Zen Mode |
| `<Space>uT` | Dim code outside the current context with Twilight |
| `:Outline` | Browse document symbols |

Incline labels split windows, Treesitter Context keeps the surrounding code
scope visible, Render Markdown improves Markdown presentation, and Smear Cursor
animates cursor movement. The active colorscheme is Gentleman Kanagawa Blur.

## Git and terminal multiplexing

Neovim shows Git changes and supports file-oriented Git actions, but LazyGit
remains the primary interface for repository operations.

There is no tmux navigation plugin. `<C-h/j/k/l>` only moves between windows
inside Neovim, while Herdr manages its own panes and shortcuts independently.

## Maintain and troubleshoot

Open the plugin manager with `:Lazy`. Review available updates before applying
them, then commit the resulting `lazy-lock.json` change with the configuration
change that required it.

Useful checks are:

```vim
:Lazy health
:checkhealth
:Mason
:LspInfo
```

If Neovim starts incorrectly, capture startup messages with:

```bash
nvim --headless '+checkhealth' '+qa'
```

Update this document whenever a user-facing shortcut changes, a language or
debug adapter is added or removed, installation requirements change, or the
three explorer roles are revised. The repository maintainer is responsible for
keeping it consistent with `shared/.config/nvim/`.
