#!/bin/bash

CONFIG_FILE=config.fish
FILE_PATH=~/.config/fish/$CONFIG_FILE

if test -f $FILE_PATH || test -h $FILE_PATH; then 
	echo "Updating Fish Config"
	rm $FILE_PATH
	ln -s $(pwd)/$CONFIG_FILE $FILE_PATH
else
	echo "Installing Fish Config"
	ln -s $(pwd)/$CONFIG_FILE $FILE_PATH
fi
