#!/bin/zsh

if test -f ~/.zshrc then
    rm ~/.zshrc
fi

stow zsh
stow kitty
stow nvim
