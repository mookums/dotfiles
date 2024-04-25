#!/bin/bash

read -p "[t]wm or tmu[x]? " start

case $start in
    [tT] )
        twm
        ;;
    *)  
        tmux
        ;;
esac
