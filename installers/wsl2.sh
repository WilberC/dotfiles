#!/bin/bash

source ./installers/base.sh # For now linux and wsl2 has similar setup

stow wsl2 

echo -e "${YELLOW}===============\nTo finish, open a new terminal.\n===============${RESET}"
