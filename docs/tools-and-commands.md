# Tools and Commands Reference

A quick reference for the tools and the commands they expose.

- **CLI tools** (lazygit, delta, difftastic, gh, eza, fzf) — managed by [aqua](https://aquaproj.github.io/) via `shared/.config/aquaproj-aqua/aqua.yaml`
- **System packages** — `shared/Brewfile` (macOS) or `shared/Aptfile` (Linux/WSL2)
- **Language runtimes** — mise

## Git tooling

| Tool | Command | What it does |
|------|---------|-------------|
| [gh](https://cli.github.com/) | `gh` | GitHub CLI — PRs, issues, releases, repo management from the terminal. Run `gh auth login` once after install |
| [lazygit](https://github.com/jesseduffield/lazygit) | `lazygit` / `lg` | Terminal UI for git — stage hunks, rebase, manage branches |
| [git-delta](https://github.com/dandavison/delta) | automatic (pager) | Syntax-highlighted `git diff` / `git show` output with side-by-side view |
| [difftastic](https://github.com/Wilfred/difftastic) | `git difftool` | Structural diff — understands syntax, not just lines |
| [bfg](https://rtyley.github.io/bfg-repo-cleaner/) | `bfg` | Rewrite git history — remove secrets or large files accidentally committed |

### Diff cheatsheet

```sh
git diff              # delta (automatic pager, side-by-side)
git difftool          # difftastic (structural/AST diff)
git difftool <file>   # difftastic on a specific file
```

In lazygit, press `<tab>` to switch between the delta and difftastic pager views.

## Shell utilities

| Tool | Command | What it does |
|------|---------|-------------|
| [eza](https://github.com/eza-community/eza) | `ls` / `ll` / `tree` | Modern `ls` replacement — icons, git status, long format, tree view |
| [aqua](https://aquaproj.github.io/) | `aqua` | CLI tool manager — installs lazygit, delta, difftastic, gh, eza, fzf. Config at `shared/.config/aquaproj-aqua/aqua.yaml`. Update all tools: `aqua update -c ~/.config/aquaproj-aqua/aqua.yaml` |
| [mise](https://mise.jdx.dev/) | `mise` | Language runtime manager (replaces nvm, rbenv, pyenv, etc.) |
| [unar](https://theunarchiver.com/command-line) | `unar <archive>` | Extract any archive format (zip, rar, 7z, tar, etc.) |
| [bfs](https://github.com/tavianator/bfs) | `bfs` | Breadth-first `find` alternative — faster on large trees, same syntax |
| [fzf](https://github.com/junegunn/fzf) | `fzf` | Fuzzy finder — interactive selector for any list; pipes well with `bfs` |

### eza aliases

```sh
ls      # list with icons, dotfiles, dirs first
ll      # long format with git status per file
tree    # directory tree (respects .gitignore)
```

### mise cheatsheet

```sh
mise use node@22       # pin a tool version for the current project
mise install           # install all versions from .mise.toml
mise ls                # list installed tools
mise exec -- <cmd>     # run a command with mise-managed tools
```

### Shell git helpers

| Command | What it does |
|---------|-------------|
| `git-exclude <pattern>` | Appends a pattern to `.git/info/exclude` in the current repo (local-only, never committed) |

```sh
git-exclude mise.toml   # ignore mise.toml only in this repo
git-exclude .env.local  # ignore a file without touching .gitignore
```

## Scripts

These live in `shared/scripts/` (stowed to `~/scripts/`). Accessible via alias.

| Script | What it does |
|--------|-------------|
| `until_failure` | Runs a command repeatedly until it exits non-zero — useful for debugging flaky tests |

## Claude Code

| Alias | Command | What it does |
|-------|---------|-------------|
| `cc` | `claude` | Claude Code CLI |
| `cca` | `claude --dangerously-skip-permissions` | Run with all permissions — no prompts |
| `ccr` | `claude --resume` | Resume the last conversation |
| `ccp` | `claude --print` | Non-interactive: print response and exit |

## Terminal & editors

| Tool | Notes |
|------|-------|
| [Ghostty](https://ghostty.org/) | Terminal emulator. Config at `shared/.config/ghostty/` |
| [Zed](https://zed.dev/) | Editor. Config at `shared/.config/zed/` |
| [libpq](https://www.postgresql.org/docs/current/libpq.html) | PostgreSQL client libs — provides `psql`, `pg_dump`, etc. |

## Dev infrastructure

| Tool | Notes |
|------|-------|
| [OrbStack](https://orbstack.dev/) | Docker Desktop replacement for macOS (faster, lighter) |
| [mise](https://mise.jdx.dev/) | Manages Node, Python, Ruby, Go, Rust versions per-project via `.mise.toml` |
