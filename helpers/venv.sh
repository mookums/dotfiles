#!/bin/bash

source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
workon $(find $WORKON_HOME -maxdepth 1 -type d ! -wholename $WORKON_HOME | fzf --keep-right | awk -F '/' '{print $NF}')
