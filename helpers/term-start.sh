#!/usr/bin/env bash

read -n 1 -p "[t]wm | [a]ttach | [g]eneric? " start
# Clears the terminal.
tput reset

case $start in
    [tT])
        twm
        ;;
    [aA])
        twm -e
        ;;
    [$'\e'])
        exit 0
        ;;
    *)  
        $SHELL
        ;;
esac
