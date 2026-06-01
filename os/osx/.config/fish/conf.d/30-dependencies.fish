# OS specific dependencies (macOS)

# Initialize Homebrew
/opt/homebrew/bin/brew shellenv | source

# Use 1Password auth sock
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Add libpq to path
fish_add_path -aP /opt/homebrew/opt/libpq/bin

# OpenSSL flags required for psycopg2 and other packages that compile C extensions
set -gx LDFLAGS "-L/opt/homebrew/opt/openssl@3/lib"
set -gx CPPFLAGS "-I/opt/homebrew/opt/openssl@3/include"

# Homebrew settings
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_ENV_HINTS 1

# gtab
alias g gtab

# Fix Chromium Gatekeeper block after install/upgrade
alias fix-chromium "xattr -dr com.apple.quarantine /Applications/Chromium.app"
