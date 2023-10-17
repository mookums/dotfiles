#!/bin/bash

if test -f ~/.config/fish/config.fish;
then 
	echo "Installing Fish Config"
	ln -s ./config.fish ~/.config/fish/config.fish
else
	echo "Updating Fish Config"
	rm ~/.config/fish/config.fish
	ln -s ./config.fish ~/.config/fish/config.fish
fi
