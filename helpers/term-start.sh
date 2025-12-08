#!/usr/bin/env bash

read -n 1 -p "[z]wm | zelli[j] | [g]eneric? " start
# Clears the terminal.
tput reset

case $start in
    [zZ])
        ${DOTFILES}/helpers/zwm.sh
        ;;
    [jJ])
        zellij -l welcome
        ;;
    [$'\e'])
        exit 0
        ;;
    *)  
        $SHELL
        ;;
esac
