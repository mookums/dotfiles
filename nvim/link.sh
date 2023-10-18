#!/bin/bash

INIT_FILE=init.lua
LUA_FOLDER=lua
INIT_FILE_PATH=~/.config/nvim/$INIT_FILE
LUA_FOLDER_PATH=~/.config/nvim/$LUA_FOLDER

if test -f $INIT_FILE || test -h $INIT_FILE; then 
	echo "Updating NeoVim Config"
	ln -sf $(pwd)/$INIT_FILE $INIT_FILE_PATH
	ln -sf $(pwd)/LUA_FOLDER $LUA_FOLDER_PATH
else
	echo "Installing NeoVim Config"
	ln -s $(pwd)/$CONFIG_FILE $FILE_PATH
fi
