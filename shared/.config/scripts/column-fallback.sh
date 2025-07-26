#!/bin/bash
# Fallback for missing column command

column() {
  # Simple fallback for missing column command
  if [ "$1" = "-t" ]; then
    shift
    cat -
  else
    cat -
  fi
}

# Export function for both bash and zsh compatibility
if [ -n "$BASH_VERSION" ]; then
  export -f column
elif [ -n "$ZSH_VERSION" ]; then
  # In zsh, functions are automatically available in subshells
  # No explicit export needed
  true
fi