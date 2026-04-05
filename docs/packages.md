# Package Inventory

Tracks every package across platforms. Use this to know what is and isn't available per OS.

## CLI Tools

Managed via `shared/Brewfile` on macOS and `shared/Aptfile` on Linux/WSL2.

| # | Name | Description | macOS (brew) | Linux/WSL2 (apt) |
|---|------|-------------|:------------:|:----------------:|
| 1 | [stow](https://www.gnu.org/software/stow/) | Symlink farm manager for dotfiles | ✓ | ✓ |
| 2 | [unar](https://theunarchiver.com/command-line) | Universal archive extractor (zip, rar, 7z, tar…) | ✓ | ✓ |
| 3 | [bfs](https://github.com/tavianator/bfs) | Breadth-first `find` alternative, same syntax | ✓ | ✓ |
| 4 | [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — interactive selector for any list | ✓ | ✓ |
| 5 | [gh](https://cli.github.com/) | GitHub CLI — PRs, issues, releases from the terminal | ✓ | ✓ ¹ |
| 6 | [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git — stage hunks, rebase, branches | ✓ | ✓ ² |
| 7 | [git-delta](https://github.com/dandavison/delta) | Syntax-highlighted diff pager for git | ✓ | ✗ manual |
| 8 | [difftastic](https://github.com/Wilfred/difftastic) | Structural AST diff — understands syntax, not lines | ✓ | ✗ manual |
| 9 | [bfg](https://rtyley.github.io/bfg-repo-cleaner/) | Rewrite git history — remove secrets or large files | ✓ | ✓ |
| 10 | [mise](https://mise.jdx.dev/) | Tool version manager (replaces nvm, pyenv, rbenv…) | ✓ | ✓ ³ |
| 11 | [libpq](https://www.postgresql.org/docs/current/libpq.html) | PostgreSQL client libs — `psql`, `pg_dump`, etc. | ✓ | ✓ ⁴ |
| 12 | [eza](https://github.com/eza-community/eza) | Modern `ls` — icons, git status, tree view | ✓ | ✓ ⁵ |

**Apt repo notes (added automatically by `install.sh`):**

- ¹ `gh` — [cli.github.com/packages](https://cli.github.com/packages)
- ² `lazygit` — PPA `ppa:lazygit-team/release`
- ³ `mise` — [mise.jdx.dev/deb](https://mise.jdx.dev/deb)
- ⁴ `libpq` — apt package is `libpq-dev`
- ⁵ `eza` — [deb.gierens.de](http://deb.gierens.de)

**Manual install on Linux/WSL2:**

- `git-delta` — download `.deb` from [releases](https://github.com/dandavison/delta/releases)
- `difftastic` — download binary from [releases](https://github.com/Wilfred/difftastic/releases)

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
