#!/bin/bash

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

# Run stow .
stow . --adopt --override