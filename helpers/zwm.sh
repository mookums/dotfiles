#!/usr/bin/env bash

SEARCH_PATHS="${ZELLIJ_SESSIONIZER_SEARCH_PATHS:-$HOME/Git}"
SPECIFIC_PATHS="${ZELLIJ_SESSIONIZER_SPECIFIC_PATHS:-$HOME/.dotfiles}"

find_git_repos() {
  local search_dir="$1"
  
  for dir in "$search_dir"/*; do
    [[ ! -d "$dir" ]] && continue
    
    if [[ -d "$dir/.git" ]]; then
      echo "$dir"
    else
      find_git_repos "$dir"
    fi
  done
}

find_dirs() {
  for path in $SEARCH_PATHS; do
    [[ -d "$path" ]] && find_git_repos "$path"
  done
  
  for path in $SPECIFIC_PATHS; do
    [[ -d "$path" ]] && echo "$path"
  done
}

# Use fzf to select
selected=$(find_dirs | sort -u | sed "s|^$HOME|~|" | fzf --prompt="Select project: ")

[[ -z "$selected" ]] && exit 0

selected="${selected/#\~/$HOME}"
session_name=$(basename "$selected")

cd "$selected" && zellij attach "$session_name" --create
