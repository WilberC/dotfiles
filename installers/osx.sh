#!/bin/bash

# Insall brew and dependencies
if (( ! ${+commands[brew]} )); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
  cd ~ && brew bundle &>/dev/nul
fi

brew install stow

cd ~/dotfiles/homebrew

brew bundle install

cd ..

# Sync local stow with dotenv configs
stow zsh
stow osx 
stow git

echo -e "${YELLOW}===============\nTo finish, open a new terminal.\n===============${RESET}"