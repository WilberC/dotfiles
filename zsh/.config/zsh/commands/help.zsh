# Help command - lists all custom shell aliases and functions
function help {
  local cmd="${1:-}"

  if [ -z "$cmd" ]; then
    # List all available commands
    cat << 'EOF'
=== Custom Shell Commands & Aliases ===

Navigation (without cd, thanks to AUTO_CD):
  ..              Go up one directory
  ~               Home directory
  ~-2             2nd most recently visited directory
  /               Root directory

File Operations:
  %=              Paste mode - paste code without prompt issues
  < file          View file contents (uses pager)

Directory Listing:
  ls              List files with icons, dotfiles, dirs first
  ll              Long format with git status per file
  tree            Directory tree view (respects .gitignore)

Git Tools:
  lg / lazygit    Terminal UI for git operations
  gh              GitHub CLI - PRs, issues, releases
  bfg             Git history rewriting (remove secrets/large files)
  delta           Syntax-highlighted git diff output
  difftastic      Structural/AST diff view

Secrets Manager:
  secrets         Manage encrypted secrets across projects
                  See ~/dotfiles/dotfiles-secrets/ for details

Development Tools:
  dev             Run development server (~/bin/dev)
  until_failure   Run command until it exits non-zero

AI Assistants:
  cc              Claude Code CLI
  cca             Claude Code with all permissions (no prompts)
  ccr             Resume last Claude conversation
  ccp             Claude Code print response and exit
  qwen            Qwen Code CLI (YOLO mode, no prompts)

Git Functions:
  git-exclude     Add pattern to .git/info/exclude (local-only)

Type 'help <command>' for detailed usage information.
EOF
  else
    # Show detailed help for specific command
    case "$cmd" in
      "%=")
        cat << 'EOF'
%= (Paste Mode)
---------------
Allows you to paste example code without the shell complaining about the
pasted prompt symbol.

Usage: Just paste your code normally after using this alias.

Example:
  %= <paste-your-code-here>
EOF
        ;;
      "alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}")
        cat << 'EOF'
File Type Associations (Text Files)
------------------------------------
These file extensions are automatically opened with your pager (less).

Usage: Just type the filename and press Enter.

Supported extensions:
  .css  .gradle .html .js  .json .md  .patch .properties .txt .xml .yml

Example:
  package.json    # Opens in pager for viewing JSON
EOF
        ;;
      "alias -s gz")
        cat << 'EOF'
alias -s gz
-----------
List gzip archive contents without extracting.

Usage:
  file.gz         # Shows compressed file listing
EOF
        ;;
      "alias -s {log,out}")
        cat << 'EOF'
alias -s {log,out}
------------------
Follow tail output for log and out files.

Usage:
  app.log         # Opens in pager with auto-follow
  server.out      # Opens in pager with auto-follow
EOF
        ;;
      "secrets")
        cat << 'EOF'
secrets (Secrets Manager)
--------------------------
Manage encrypted secrets across projects.

Commands:
  secrets link                    Symlink .env from secrets repo to current project
  secrets unlink                  Remove the .env symlink
  secrets status                  Show link status for current directory
  secrets link-all                Create all symlinks defined in config.json
  secrets add <category> <key>    Register new project (work|personal|others)
  secrets list                    Show all projects and their link status
  secrets encrypt                 Encrypt secrets/ → secrets.zip.enc
  secrets decrypt [-f]            Decrypt secrets.zip.enc → secrets/

Examples:
  secrets add work outcode/portal-backend
  cd ~/Projects/Work/outcode/portal-backend && secrets link
  secrets encrypt                # After editing, encrypt and push
EOF
        ;;
      "lg")
        cat << 'EOF'
lg (lazygit)
------------
Terminal-based UI for git operations.

Usage:
  lg                    # Launch lazygit
  lazygit               # Same as above (full command name)

Features:
  - Stage hunks, rebase, manage branches
  - View diffs with syntax highlighting
  - Press TAB to switch between delta and difftastic views
EOF
        ;;
      "dev")
        cat << 'EOF'
dev
---
Run your development server.

Usage:
  dev                    # Start the development server

Location: ~/bin/dev
EOF
        ;;
      "until_failure")
        cat << 'EOF'
until_failure
-------------
Run a command repeatedly until it exits with non-zero status.

Usage:
  until_failure <command>

Example:
  until_failure npm test    # Keep running tests until one fails
EOF
        ;;
      "cc"|"cca"|"ccr"|"ccp")
        cat << 'EOF'
Claude Code Aliases
--------------------
  cc         - claude                           Standard CLI
  cca        - claude --dangerously-skip-permissions  All permissions, no prompts
  ccr        - claude --resume                  Resume last conversation
  ccp        - claude --print                   Non-interactive print and exit

Examples:
  cc <prompt>                     # Ask Claude a question
  cca "init all"                 # Initialize with full permissions
  ccr                            # Continue previous conversation
EOF
        ;;
      "qwen")
        cat << 'EOF'
qwen (Qwen Code)
----------------
Qwen AI assistant with YOLO mode enabled.

Usage:
  qwen <command>     # Run Qwen command directly
  qwen --help        # See all available Qwen commands

Mode: YOLO (You Only Learn Once) - no permission prompts by default
EOF
        ;;
      "ls")
        cat << 'EOF'
ls (eza alias)
--------------
Modern replacement for ls with icons and git status.

Usage:
  ls              # List files with icons, dotfiles visible, dirs first
EOF
        ;;
      "ll")
        cat << 'EOF'
ll (eza long alias)
-------------------
Long format listing with git status indicators.

Usage:
  ll              # Long format with git status per file
EOF
        ;;
      "tree")
        cat << 'EOF'
tree (eza tree alias)
----------------------
Directory tree view that respects .gitignore.

Usage:
  tree            # Show directory tree with git info
EOF
        ;;
      "git-exclude")
        cat << 'EOF'
git-exclude <pattern>
---------------------
Add a pattern to the current repository's .git/info/exclude file.
This creates a local-only exclusion that is never committed.

Usage:
  git-exclude <pattern>

Examples:
  git-exclude .env.local      # Ignore .env.local in this repo only
  git-exclude node_modules    # Exclude node_modules locally
  git-exclude "*.log"         # Exclude all log files locally

Note: This does not modify .gitignore - it's purely local to this repository.
EOF
        ;;
      "gh")
        cat << 'EOF'
gh (GitHub CLI)
---------------
Full-featured GitHub command-line interface.

Common commands:
  gh auth login                    # Login to GitHub
  gh pr create                     # Create a new pull request
  gh pr list                       # List pull requests
  gh issue create                  # Create a new issue
  gh repo clone <owner/repo>       # Clone a repository
EOF
        ;;
      "bfg")
        cat << 'EOF'
bfg (Before Git)
----------------
Rewrite git history - useful for removing accidentally committed secrets or large files.

Common use cases:
  Remove sensitive data from history
  Replace large files with smaller alternatives
EOF
        ;;
      "delta"|"difftastic")
        cat << 'EOF'
delta / difftastic
-------------------
Syntax-highlighted diff viewers that understand file structure and syntax.

Usage:
  git diff              # Shows delta (automatic pager, side-by-side view)
  git difftool          # Shows difftastic (structural/AST diff)
  git difftool <file>   # Show difftastic for a specific file

In lazygit: Press TAB to switch between delta and difftastic views.
EOF
        ;;
      *)
        echo "Unknown command: $cmd"
        echo ""
        cat << 'EOF'
Available commands for detailed help:
  %=              Paste mode
  < file          View file contents
  secrets         Secrets manager
  lg / lazygit    Git terminal UI
  dev             Development server
  until_failure   Run command until failure
  cc / cca / ccr / ccp  Claude Code aliases
  qwen            Qwen Code CLI
  ls              List files (eza)
  ll              Long format (eza)
  tree            Directory tree
  git-exclude     Local git excludes
EOF
        ;;
    esac
  fi
}
