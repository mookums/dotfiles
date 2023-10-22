#!/bin/bash

INIT_FILE=init.lua
LUA_FOLDER=lua
INIT_FILE_PATH=~/.config/nvim/$INIT_FILE
NVIM_FOLDER_PATH=~/.config/nvim/
LUA_FOLDER_PATH=$NVIM_FOLDER_PATH$LUA_FOLDER

if test -f $INIT_FILE_PATH || test -h $INIT_FILE_PATH; then 
	echo "Updating NeoVim Config"
	ln -sf $(pwd)/$INIT_FILE $INIT_FILE_PATH
	rm -rf $LUA_FOLDER_PATH
	ln -s $(pwd)/$LUA_FOLDER $NVIM_FOLDER_PATH
else
	echo "Installing NeoVim Config"
	mkdir -p $NVIM_FOLDER_PATH
	ln -s $(pwd)/$INIT_FILE $INIT_FILE_PATH
	ln -s $(pwd)/$LUA_FOLDER $NVIM_FOLDER_PATH
fi
