#!/bin/zsh

for fn in $HOME/.config/zsh/commands/*.zsh(N); do
  z4h source -c -- ${fn}
done
