#!/bin/zsh

for fn in ${ZDOTDIR}/commands/*.zsh; do
  z4h source -c -- ${fn}
done
