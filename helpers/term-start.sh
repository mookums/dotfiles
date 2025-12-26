#!/usr/bin/env bash

read -n 1 -p "[t]wm | [a]ttack | [z]wm | zelli[j] | [g]eneric? " start
# Clears the terminal.
tput reset

case $start in
    [tT])
        twm
        ;;
    [aA])
        twm -e
        ;;
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
