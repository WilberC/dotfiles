function help {
  local cmd="${1:-}"

  local reset='\033[0m'
  local bold='\033[1m'
  local cyan='\033[36m'
  local yellow='\033[33m'
  local green='\033[32m'
  local dim='\033[2m'

  _help_section() { printf "\n${yellow}${bold}$1${reset}\n"; }
  _help_cmd()     { printf "  ${cyan}%-16s${reset} ${dim}$2${reset}\n" "$1"; }
  _help_detail()  { printf "  ${green}$1${reset}\n"; }
  _help_example() { printf "  ${dim}$1${reset}\n"; }

  if [ -z "$cmd" ]; then
    printf "${bold}=== Custom Shell Commands & Aliases ===${reset}\n"

    _help_section "Navigation (AUTO_CD — no cd needed)"
    _help_cmd ".."    "Go up one directory"
    _help_cmd "~"     "Home directory"
    _help_cmd "~-2"   "2nd most recently visited directory"

    _help_section "File Operations"
    _help_cmd "%="      "Paste mode (paste code without prompt issues)"
    _help_cmd "< file"  "View file contents in pager"

    _help_section "Directory Listing"
    _help_cmd "ls"     "List files with icons, dotfiles, dirs first"
    _help_cmd "ll"     "Long format with git status per file"
    _help_cmd "tree"   "Directory tree (respects .gitignore)"
    _help_cmd "treed"  "Dirs only tree"
    _help_cmd "tt"     "treed -L 2"
    _help_cmd "ttt"    "treed -L 3"

    _help_section "Git"
    _help_cmd "lg"           "lazygit — terminal UI for git"
    _help_cmd "git-exclude"  "Add pattern to .git/info/exclude (local-only)"

    _help_section "Secrets"
    _help_cmd "secrets"  "Manage encrypted secrets across projects"

    _help_section "Development"
    _help_cmd "dev"            "Run development server (bin/dev)"
    _help_cmd "until_failure"  "Run command until it exits non-zero"

    _help_section "AI Assistants"
    _help_cmd "cc"    "claude"
    _help_cmd "cca"   "claude --dangerously-skip-permissions"
    _help_cmd "ccr"   "claude --resume"
    _help_cmd "ccp"   "claude --print"
    _help_cmd "qwen"  "qwen --yolo"

    _help_section "Network"
    _help_cmd "myip"       "Get public IP"
    _help_cmd "listening"  "List TCP listening ports (optional: listening <pattern>)"

    printf "\n${dim}Type 'help <command>' for details.${reset}\n\n"

    unfunction _help_section _help_cmd _help_detail _help_example
  else
    case "$cmd" in
      "%=")
        printf "${cyan}${bold}%=${reset} ${dim}Paste Mode${reset}\n"
        printf "Paste code without shell complaining about prompt symbols.\n"
        printf "\n${yellow}Usage:${reset}\n"
        _help_example "%= <paste-your-code>"
        ;;
      "secrets")
        printf "${cyan}${bold}secrets${reset} — Manage encrypted secrets across projects\n"
        printf "\n${yellow}Commands:${reset}\n"
        _help_cmd "secrets link"              "Symlink .env from secrets repo to current project"
        _help_cmd "secrets unlink"            "Remove the .env symlink"
        _help_cmd "secrets status"            "Show link status for current directory"
        _help_cmd "secrets link-all"          "Create all symlinks defined in config.json"
        _help_cmd "secrets add <cat> <key>"   "Register new project (work|personal|others)"
        _help_cmd "secrets list"              "Show all projects and their link status"
        _help_cmd "secrets encrypt"           "Encrypt secrets/ → secrets.zip.enc"
        _help_cmd "secrets decrypt [-f]"      "Decrypt secrets.zip.enc → secrets/"
        printf "\n${yellow}Examples:${reset}\n"
        _help_example "secrets add work myorg/myrepo"
        _help_example "cd ~/Projects/myrepo && secrets link"
        ;;
      "git-exclude")
        printf "${cyan}${bold}git-exclude${reset} <pattern>\n"
        printf "Add pattern to .git/info/exclude — local only, never committed.\n"
        printf "\n${yellow}Examples:${reset}\n"
        _help_example "git-exclude .env.local"
        _help_example 'git-exclude "*.log"'
        ;;
      "until_failure")
        printf "${cyan}${bold}until_failure${reset} <command>\n"
        printf "Run command repeatedly until it exits non-zero.\n"
        printf "\n${yellow}Example:${reset}\n"
        _help_example "until_failure npm test"
        ;;
      "myip")
        printf "${cyan}${bold}myip${reset}\n"
        printf "Get your public IP via Cloudflare DNS.\n"
        ;;
      "listening")
        printf "${cyan}${bold}listening${reset} [pattern]\n"
        printf "List processes listening on TCP ports.\n"
        printf "\n${yellow}Examples:${reset}\n"
        _help_example "listening          # all"
        _help_example "listening 3000     # filter by port or name"
        ;;
      "cc"|"cca"|"ccr"|"ccp")
        printf "${cyan}${bold}Claude Code aliases${reset}\n"
        _help_cmd "cc"   "claude"
        _help_cmd "cca"  "claude --dangerously-skip-permissions"
        _help_cmd "ccr"  "claude --resume"
        _help_cmd "ccp"  "claude --print"
        ;;
      "qwen")
        printf "${cyan}${bold}qwen${reset} — Qwen Code in YOLO mode (no permission prompts)\n"
        printf "\n${yellow}Usage:${reset}\n"
        _help_example "qwen <prompt>"
        ;;
      "lg")
        printf "${cyan}${bold}lg${reset} — lazygit terminal UI\n"
        printf "Stage hunks, rebase, manage branches, view diffs.\n"
        printf "TAB to switch between delta and difftastic views.\n"
        ;;
      "tree"|"treed"|"tt"|"ttt")
        printf "${cyan}${bold}tree/treed/tt/ttt${reset}\n"
        _help_cmd "tree"   "eza --tree (respects .gitignore)"
        _help_cmd "treed"  "tree --only-dirs"
        _help_cmd "tt"     "treed -L 2"
        _help_cmd "ttt"    "treed -L 3"
        printf "\n${yellow}Examples:${reset}\n"
        _help_example "tree --levels=2"
        _help_example "treed ~/projects"
        ;;
      *)
        printf "${dim}No detailed help for '${cmd}'. Try: ${cmd} --help${reset}\n"
        ;;
    esac
    printf "\n"
    unfunction _help_section _help_cmd _help_detail _help_example
  fi
}
