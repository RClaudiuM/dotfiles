#!/bin/bash
# File navigation utilities using fzf

# Interactive file navigation with preview
function fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf --preview 'ls -la {}')
  if [ -n "$dir" ]; then
    cd "$dir"
    echo "Changed to: $dir"
  fi
}

# Interactive file opening
function fopen() {
  local file
  file=$(find ${1:-.} -type f -not -path "*/node_modules/*" -not -path "*/\.*" | fzf --preview 'head -100 {}')
  if [ -n "$file" ]; then
    ${EDITOR:-vim} "$file"
  fi
}

# Interactive file search
function fsearch() {
  local query="${1:-.}"
  local file
  file=$(find . -type f -not -path "*/node_modules/*" -not -path "*/\.*" -not -path "*/\build/*" | 
         fzf --query "$query" --preview 'head -100 {}')
  if [ -n "$file" ]; then
    ${EDITOR:-vim} "$file"
  fi
}
