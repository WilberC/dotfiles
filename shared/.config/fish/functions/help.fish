function help --description 'Show custom shell commands and aliases'
    set -l cmd ""
    if test (count $argv) -ge 1
        set cmd $argv[1]
    end

    set -l R (set_color normal)
    set -l B (set_color --bold)
    set -l C (set_color cyan)
    set -l Y (set_color yellow)
    set -l D (set_color brblack)

    if test -z "$cmd"
        printf "$B=== Custom Shell Commands & Aliases ===$R\n"

        printf "\n$Y$B Directory Listing$R\n"
        printf "  $C%-16s$R $D%s$R\n" ls    "List files with icons, dotfiles, dirs first"
        printf "  $C%-16s$R $D%s$R\n" ll    "Long format with git status per file"
        printf "  $C%-16s$R $D%s$R\n" tree  "Directory tree (respects .gitignore)"
        printf "  $C%-16s$R $D%s$R\n" treed "Dirs only tree"
        printf "  $C%-16s$R $D%s$R\n" tt    "treed -L 2"
        printf "  $C%-16s$R $D%s$R\n" ttt   "treed -L 3"

        printf "\n$Y$B Git$R\n"
        printf "  $C%-16s$R $D%s$R\n" lg           "lazygit — terminal UI for git"
        printf "  $C%-16s$R $D%s$R\n" git-exclude  "Add pattern to .git/info/exclude (local-only)"

        printf "\n$Y$B Development$R\n"
        printf "  $C%-16s$R $D%s$R\n" dev            "Run development server (bin/dev)"
        printf "  $C%-16s$R $D%s$R\n" until_failure  "Run command until it exits non-zero"
        printf "  $C%-16s$R $D%s$R\n" pi             "pi via mise (node@lts)"
        printf "  $C%-16s$R $D%s$R\n" codex          "codex via mise (node@lts)"

        printf "\n$Y$B AI Assistants$R\n"
        printf "  $C%-16s$R $D%s$R\n" cc   "claude"
        printf "  $C%-16s$R $D%s$R\n" cca  "claude --dangerously-skip-permissions"
        printf "  $C%-16s$R $D%s$R\n" ccr  "claude --resume"
        printf "  $C%-16s$R $D%s$R\n" ccp  "claude --print"

        printf "\n$Y$B Remote$R\n"
        printf "  $C%-16s$R $D%s$R\n" zr  "Open folder on r0n1n via Zed SSH remote"

        printf "\n$Y$B Network$R\n"
        printf "  $C%-16s$R $D%s$R\n" myip       "Get public IP"
        printf "  $C%-16s$R $D%s$R\n" listening  "List TCP listening ports (optional: listening <pattern>)"

        printf "\n$D Type 'help <command>' for details.$R\n\n"
    else
        switch $cmd
            case git-exclude
                printf "$C$B git-exclude$R <pattern>\n"
                printf "Add pattern to .git/info/exclude — local only, never committed.\n"
                printf "\n$Y Examples:$R\n"
                printf "  $D git-exclude .env.local$R\n"
                printf "  $D git-exclude '*.log'$R\n\n"
            case until_failure
                printf "$C$B until_failure$R <command>\n"
                printf "Run command repeatedly until it exits non-zero.\n"
                printf "\n$Y Example:$R\n"
                printf "  $D until_failure npm test$R\n\n"
            case cc cca ccr ccp
                printf "$C$B Claude Code aliases$R\n"
                printf "  $C%-4s$R $D%s$R\n" cc   claude
                printf "  $C%-4s$R $D%s$R\n" cca  "claude --dangerously-skip-permissions"
                printf "  $C%-4s$R $D%s$R\n" ccr  "claude --resume"
                printf "  $C%-4s$R $D%s$R\n" ccp  "claude --print\n"
            case lg
                printf "$C$B lg$R — lazygit terminal UI\n"
                printf "Stage hunks, rebase, manage branches, view diffs.\n"
                printf "TAB to switch between delta and difftastic views.\n\n"
            case tree treed tt ttt
                printf "$C$B tree/treed/tt/ttt$R\n"
                printf "  $C%-6s$R $D%s$R\n" tree  "eza --tree (respects .gitignore)"
                printf "  $C%-6s$R $D%s$R\n" treed "tree --only-dirs"
                printf "  $C%-6s$R $D%s$R\n" tt    "treed -L 2"
                printf "  $C%-6s$R $D%s$R\n" ttt   "treed -L 3"
                printf "\n$Y Examples:$R\n"
                printf "  $D tree --level=2$R\n"
                printf "  $D treed ~/projects$R\n\n"
            case myip
                printf "$C$B myip$R\n"
                printf "Get your public IP via Cloudflare DNS.\n\n"
            case listening
                printf "$C$B listening$R [pattern]\n"
                printf "List processes listening on TCP ports.\n"
                printf "\n$Y Examples:$R\n"
                printf "  $D listening           # all$R\n"
                printf "  $D listening 3000      # filter by port or name$R\n\n"
            case zr
                printf "$C$B zr$R [path]\n"
                printf "Open a folder on r0n1n via Zed SSH remote. Defaults to current directory.\n"
                printf "\n$Y Examples:$R\n"
                printf "  $D zr                  # current dir$R\n"
                printf "  $D zr projects/myapp   # relative to home$R\n\n"
            case '*'
                printf "$D No detailed help for '$cmd'. Try: $cmd --help$R\n\n"
        end
    end
end
