#!/bin/bash
# macOS-specific setup script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command-line arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
fi

echo -e "${BLUE}🍎 Setting up macOS-specific configurations...${NC}"

# Install Nix if not present (for nix-darwin)
if ! command -v nix &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would install Nix with: sh <(curl -L https://nixos.org/nix/install) --daemon${NC}"
        echo -e "${YELLOW}[DRY RUN] After Nix installation, you would need to restart your terminal and run this script again${NC}"
    else
        echo -e "${BLUE}Installing Nix...${NC}"
        sh <(curl -L https://nixos.org/nix/install) --daemon
        echo -e "${YELLOW}⚠️  Nix installed! Please restart your terminal and run this script again${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✅ Nix is already installed${NC}"
fi

# Make scripts executable
if [ -d ~/.config/scripts ]; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute: chmod +x ~/.config/scripts/*.sh${NC}"
    else
        chmod +x ~/.config/scripts/*.sh
        echo -e "${GREEN}✅ Made custom scripts executable${NC}"
    fi
fi

# Setup nix-darwin
if [ -d ~/.config/nix-darwin ]; then
    echo -e "${BLUE}🔨 Setting up nix-darwin...${NC}"
    if command -v darwin-rebuild &>/dev/null; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would execute: sudo darwin-rebuild switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS --verbose${NC}"
        else
            sudo darwin-rebuild switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS --verbose
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would execute: nix run nix-darwin --experimental-features \"nix-command flakes\" -- switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS${NC}"
        else
            nix run nix-darwin --experimental-features "nix-command flakes" -- switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS
        fi
    fi
    echo -e "${GREEN}✅ nix-darwin setup complete${NC}"
else
    echo -e "${YELLOW}⚠️  No nix-darwin configuration found${NC}"
fi

echo -e "${GREEN}✅ macOS setup complete!${NC}"
