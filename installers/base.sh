#!/bin/bash

# Update package manager
sudo apt update -y && sudo apt upgrade -y

# Set locales if missing
add_locale() {
    if ! grep -qxF "$1" /etc/default/locale; then
        echo "$1" | sudo tee -a /etc/default/locale
    fi
}

add_locale 'LANGUAGE=en_US.UTF-8'
add_locale 'LC_ALL=en_US.UTF-8'
add_locale 'LANG=en_US.UTF-8'
add_locale 'LC_CTYPE=en_US.UTF-8'

# Install zsh and stow
sudo apt install -y zsh stow

# Install locales 
sudo locale-gen en_US.UTF-8
sudo locale-gen C.UTF-8

# Set zsh as default shell
chsh -s $(which zsh)

# Sync local stow with dotenv configs
cd ~/dotfiles 
stow zsh 
stow git
