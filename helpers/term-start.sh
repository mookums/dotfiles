#!/bin/bash

read -n 1 -p "[t]wm | tmu[x] | [g]eneric? " start
# Clears the terminal.
tput reset

case $start in
    [tT] )
        twm
        ;;
    [xX])  
        tmux
        ;;
    [$'\e'])
        exit 0
        ;;
    *)  
        echo $start
        $SHELL
        ;;
esac
