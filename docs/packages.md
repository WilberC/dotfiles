# Package Inventory

Tracks every package across platforms. Use this to know what is and isn't available per OS.

## CLI Tools — aqua (cross-platform)

Managed via aqua on all platforms. Config: `shared/.config/aquaproj-aqua/aqua.yaml`.

| # | Name | Description |
|---|------|-------------|
| 1 | [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — interactive selector for any list |
| 2 | [gh](https://cli.github.com/) | GitHub CLI — PRs, issues, releases from the terminal |
| 3 | [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git — stage hunks, rebase, branches |
| 4 | [git-delta](https://github.com/dandavison/delta) | Syntax-highlighted diff pager for git |
| 5 | [difftastic](https://github.com/Wilfred/difftastic) | Structural AST diff — understands syntax, not lines |
| 6 | [eza](https://github.com/eza-community/eza) | Modern `ls` — icons, git status, tree view |

---

## System Packages

Managed via `shared/Brewfile` on macOS and `shared/Aptfile` on Linux/WSL2.

| # | Name | Description | macOS (brew) | Linux/WSL2 (apt) |
|---|------|-------------|:------------:|:----------------:|
| 1 | [zsh](https://www.zsh.org/) | Default shell | built-in | ✓ |
| 2 | [stow](https://www.gnu.org/software/stow/) | Symlink farm manager for dotfiles | ✓ | ✓ |
| 3 | [unar](https://theunarchiver.com/command-line) | Universal archive extractor (zip, rar, 7z, tar…) | ✓ | ✓ |
| 4 | [bfs](https://github.com/tavianator/bfs) | Breadth-first `find` alternative, same syntax | ✓ | ✓ |
| 5 | [mise](https://mise.jdx.dev/) | Language runtime manager (replaces nvm, pyenv, rbenv…) | ✓ | ✓ ¹ |
| 6 | [libpq](https://www.postgresql.org/docs/current/libpq.html) | PostgreSQL client libs — `psql`, `pg_dump`, etc. | ✓ | ✓ ² |
| 7 | [bfg](https://rtyley.github.io/bfg-repo-cleaner/) | Rewrite git history — remove secrets or large files | ✓ | ✗ manual ³ |

**Apt repo notes (added automatically by `01-packages.sh`):**

- ¹ `mise` — [mise.jdx.dev/deb](https://mise.jdx.dev/deb)
- ² `libpq` — apt package is `libpq-dev`
- ³ `bfg` — JAR file, requires Java; download from [releases](https://rtyley.github.io/bfg-repo-cleaner/)

---

## Apps / GUI

Managed via cask on macOS. On Linux/WSL2 all apps require manual install.

| # | Name | Description | macOS (cask) | Linux/WSL2 |
|---|------|-------------|:------------:|:----------:|
| 1 | [Ghostty](https://ghostty.org/) | Terminal emulator | ✓ | ✗ manual |
| 2 | [JetBrains Mono Nerd Font](https://www.nerdfonts.com/) | Monospace font with icons for terminal/editor | ✓ | ✗ manual |
| 3 | [OrbStack](https://orbstack.dev/) | Docker Desktop replacement (macOS only) | ✓ | ✗ N/A |
| 4 | [Zed](https://zed.dev/) | Fast code editor | ✓ | ✗ manual |
| 5 | [Claude Code](https://docs.anthropic.com/claude-code) | AI coding assistant | ✓ | ✗ manual |
| 6 | [VSCode](https://code.visualstudio.com/) | Code editor (extensions sync via account) | ✗ suggested | ✗ manual |
