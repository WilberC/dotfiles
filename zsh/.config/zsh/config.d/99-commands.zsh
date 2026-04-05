#!/bin/zsh

for fn in ${ZDOTDIR}/commands/*.zsh(N); do
  z4h source -c -- ${fn}
done
