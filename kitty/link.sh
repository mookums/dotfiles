#!/bin/bash

CONFIG_FILE=kitty.conf
FILE_PATH=~/.config/kitty/$CONFIG_FILE

if test -f $FILE_PATH || test -h $FILE_PATH; then 
	echo "Updating Kitty Config"
	ln -sf $(pwd)/$CONFIG_FILE $FILE_PATH
else
	echo "Installing Kitty Config"
	ln -s $(pwd)/$CONFIG_FILE $FILE_PATH
fi
