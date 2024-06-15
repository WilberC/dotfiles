<h2 align="center">kucho/dotfiles</h2>

## Prerequisites
1. [GNU/Stow](https://www.gnu.org/software/stow/)

##  Installation

1. Clone onto your machine:
  ```bash
  git clone git@github.com:kucho/dotfiles.git ~/dotfiles
  ```

2. Setup personal credentials:
  ```bash
  # Clone your personal keys files inside the dotfiles folder
  # For more context go to the keys_template README
  git clone git@github.com:WilberC/keys_template.git keys
  stow keys
  ```

3. Install the configuration files you need/want:
  ```bash
  cd ~/dotfiles
  stow zsh
  stow git
  stow osx
  ```

4. Edit/Replace/Create new config files and restow them:
  ```bash
  stow -R zsh # the folder that contains the new config file
  ```

## Known issues

<details>
  <summary><b>WSL2</b></summary>


- If you're getting `"warning: Empty last update token."` it is due to `fsmonitor` is `true` at the `git/.gitconfig` file. There is two solucions for that
    - The not recommended one is to simple set it as `false`
    - The second one is to upgrade the `git version` because it was solved at `2.36.1` so to upgrade it is as simple as:
    ```bash
    git --version # it must be >= 2.36.1
    # if not let's upgrade git
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update && sudo apt upgrade -y
    ```
</details>
