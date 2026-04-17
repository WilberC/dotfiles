function help {
  local cmd="${1:-}"

  if [ -z "$cmd" ]; then
    cat << 'EOF'
=== Custom Shell Commands & Aliases ===

Navigation (AUTO_CD — no cd needed):
  ..              Go up one directory
  ~               Home directory
  ~-2             2nd most recently visited directory

File Operations:
  %=              Paste mode (paste code without prompt issues)
  < file          View file contents in pager

Directory Listing:
  ls              List files with icons, dotfiles, dirs first
  ll              Long format with git status per file
  tree            Directory tree (respects .gitignore)
  treed           Dirs only tree
  tt              treed -L 2
  ttt             treed -L 3

Git:
  lg              lazygit — terminal UI for git
  git-exclude     Add pattern to .git/info/exclude (local-only, not committed)

Secrets:
  secrets         Manage encrypted secrets across projects

Development:
  dev             Run development server (bin/dev)
  until_failure   Run command until it exits non-zero

AI Assistants:
  cc              claude
  cca             claude --dangerously-skip-permissions
  ccr             claude --resume
  ccp             claude --print
  qwen            qwen --yolo

Network:
  myip            Get public IP
  listening       List TCP listening ports (optional: listening <pattern>)

Type 'help <command>' for details.
EOF
  else
    case "$cmd" in
      "%=")
        cat << 'EOF'
%= (Paste Mode)
Paste code into terminal without shell complaining about prompt symbols.
Usage: %= <paste-your-code>
EOF
        ;;
      "secrets")
        cat << 'EOF'
secrets — Manage encrypted secrets across projects
  secrets link                    Symlink .env from secrets repo to current project
  secrets unlink                  Remove the .env symlink
  secrets status                  Show link status for current directory
  secrets link-all                Create all symlinks defined in config.json
  secrets add <category> <key>    Register new project (work|personal|others)
  secrets list                    Show all projects and their link status
  secrets encrypt                 Encrypt secrets/ → secrets.zip.enc
  secrets decrypt [-f]            Decrypt secrets.zip.enc → secrets/

Examples:
  secrets add work myorg/myrepo
  cd ~/Projects/myrepo && secrets link
EOF
        ;;
      "git-exclude")
        cat << 'EOF'
git-exclude <pattern>
Add pattern to .git/info/exclude — local only, never committed.

Examples:
  git-exclude .env.local
  git-exclude "*.log"
EOF
        ;;
      "until_failure")
        cat << 'EOF'
until_failure <command>
Run command repeatedly until it exits non-zero.

Example:
  until_failure npm test
EOF
        ;;
      "myip")
        cat << 'EOF'
myip
Get your public IP via Cloudflare DNS.
EOF
        ;;
      "listening")
        cat << 'EOF'
listening [pattern]
List processes listening on TCP ports.

Examples:
  listening          # all
  listening 3000     # filter by port or name
EOF
        ;;
      "cc"|"cca"|"ccr"|"ccp")
        cat << 'EOF'
Claude Code aliases:
  cc    claude
  cca   claude --dangerously-skip-permissions
  ccr   claude --resume
  ccp   claude --print
EOF
        ;;
      "qwen")
        cat << 'EOF'
qwen — Qwen Code in YOLO mode (no permission prompts)
Usage: qwen <prompt>
EOF
        ;;
      "lg")
        cat << 'EOF'
lg — lazygit terminal UI
  Stage hunks, rebase, manage branches, view diffs
  TAB to switch between delta and difftastic views
EOF
        ;;
      "tree"|"treed"|"tt"|"ttt")
        cat << 'EOF'
tree      eza --tree (respects .gitignore)
treed     tree --only-dirs
tt        treed -L 2
ttt       treed -L 3

Examples:
  tree --levels=2
  treed ~/projects
EOF
        ;;
      *)
        echo "No detailed help for '$cmd'. Try: $cmd --help"
        ;;
    esac
  fi
}
