#!/bin/zsh

znap source asdf-vm/asdf asdf.sh

if ! command_exists direnv; then
  asdf plugin-add direnv && asdf install direnv latest && asdf global direnv latest &>/dev/null
fi

znap eval asdf-community/asdf-direnv "asdf exec $(asdf which direnv) hook zsh"

fpath+=( ~[asdf-community/asdf-direnv]/completions )

source $HOME/.agent-bridge.sh
