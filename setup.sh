#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install GNU Stow
if ! command -v stow &> /dev/null
then
    echo "GNU Stow not found, installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install stow
    else
        sudo apt-get update
        sudo apt-get install -y stow
    fi
else
    echo "GNU Stow is already installed"
fi

# Install fzf if not present and on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]] && ! command_exists fzf; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
elif [[ "$OSTYPE" == "linux-gnu"* ]] && command_exists fzf; then
    echo "fzf is already installed"
fi

# Remove existing .zshrc file
if [ -f ~/.zshrc ]; then
    echo "Removing existing ~/.zshrc file"
    rm ~/.zshrc
fi

# Run stow .
stow . 