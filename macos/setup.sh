#!/bin/bash
# macOS-specific setup script

echo "🍎 Setting up macOS-specific configurations..."

# Install Nix if not present (for nix-darwin)
if ! command -v nix &>/dev/null; then
    echo "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    echo "Please restart your terminal and run this script again"
    exit 0
fi

# Make scripts executable
if [ -d ~/.config/scripts ]; then
    chmod +x ~/.config/scripts/*.sh
    echo "✅ Made custom scripts executable"
fi

# Setup nix-darwin
if [ -d ~/.config/nix-darwin ]; then
    echo "🔨 Setting up nix-darwin..."
    if command -v darwin-rebuild &>/dev/null; then
        sudo darwin-rebuild switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS --verbose
    else
        nix run nix-darwin --experimental-features "nix-command flakes" -- switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS
    fi
    echo "✅ nix-darwin setup complete"
else
    echo "⚠️  No nix-darwin configuration found"
fi

echo "✅ macOS setup complete!"
