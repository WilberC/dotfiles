#!/bin/bash

source ./installers/base.sh # For now linux and wsl2 has similar setup

stow linux

echo -e "${YELLOW}===============\nTo finish logout and login (or restart).\n===============${RESET}"
