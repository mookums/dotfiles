#!/bin/bash

CONFIG_FILE=kitty.conf
THEME_FILE=theme.conf
FILE_PATH=~/.config/kitty/$CONFIG_FILE
THEME_PATH=~/.config/kitty/$THEME_FILE

if test -f $FILE_PATH || test -h $FILE_PATH; then 
	echo "Updating Kitty Config"
	ln -sf $(pwd)/$CONFIG_FILE $FILE_PATH
    ln -sf $(pwd)/$THEME_FILE $THEME_PATH
else
	echo "Installing Kitty Config"
	ln -s $(pwd)/$CONFIG_FILE $FILE_PATH
    ln -s $(pwd)/$THEME_FILE $THEME_PATH
fi
