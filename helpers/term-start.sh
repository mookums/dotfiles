#!/usr/bin/env bash

read -n 1 -p "[z]ellij | [g]eneric? " start
# Clears the terminal.
tput reset

case $start in
    [zZ])
        zellij -l welcome
        ;;
    [$'\e'])
        exit 0
        ;;
    *)  
        $SHELL
        ;;
esac
