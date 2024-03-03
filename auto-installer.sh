#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m' # Reset color to default

# Prompt for sudo password at the beginning
sudo -v

# Identify OS
if [ "$(uname)" == "Darwin" ]; then
    echo -e "${GREEN}You are running macOS.${RESET}"
    source ./installers/osx.sh
elif [ -n "$WSL_INTEROP" ]; then
    echo -e "${GREEN}Running Windows Subsystem for Linux (WSL) on Windows.${RESET}"
    source ./installers/wsl2.sh
elif [ "$(uname)" == "Linux" ]; then
    echo -e "${GREEN}You are running Linux.${RESET}"
    source ./installers/linux.sh
else
    echo -e "${RED}You are running a different operating system.${RESET}"
fi
