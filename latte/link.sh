#!/bin/bash

CONFIG_FILE=Muki.layout.latte
FILE_PATH=~/.config/latte/$CONFIG_FILE

if test -f $FILE_PATH || test -h $FILE_PATH; then 
	echo "Updating Muki's Latte Layout"
	rm $FILE_PATH 
	ln $(pwd)/$CONFIG_FILE $FILE_PATH
else
	echo "Installing Muki's Latte Layout"
	ln $(pwd)/$CONFIG_FILE $FILE_PATH
fi
