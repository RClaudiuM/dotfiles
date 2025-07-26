#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /.dockerenv ] || grep -q 'container' /proc/1/cgroup 2>/dev/null; then
            echo "devcontainer"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

PLATFORM=$(detect_platform)
echo -e "${GREEN}🚀 Setting up dotfiles for $PLATFORM...${NC}"

# Install stow if not present
install_stow() {
    if ! command_exists stow; then
        echo -e "${BLUE}Installing GNU Stow...${NC}"
        case $PLATFORM in
            "macos")
                if command_exists brew; then
                    brew install stow
                else
                    echo -e "${RED}ERROR: Homebrew not found. Please install Homebrew first.${NC}"
                    exit 1
                fi
                ;;
            "devcontainer"|"linux")
                sudo apt-get update && sudo apt-get install -y stow
                ;;
            *)
                echo -e "${RED}ERROR: Unknown platform for stow installation${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}✅ GNU Stow is already installed${NC}"
    fi
}

# Main installation function
main() {
    echo -e "${BLUE}Platform detected: $PLATFORM${NC}"
    
    # Install stow first
    install_stow
    
    # Platform-specific setup
    case $PLATFORM in
        "macos")
            echo -e "${BLUE}🍎 Setting up macOS configuration...${NC}"
            
            # Remove existing dotfiles that might conflict
            [ -f ~/.zshrc ] && rm ~/.zshrc
            [ -f ~/.p10k.zsh ] && rm ~/.p10k.zsh
            [ -f ~/.bashrc ] && rm ~/.bashrc

            # Stow shared scripts first
            echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
            stow -t ~ shared
            
            # Run shared bash setup for tool installation
            echo -e "${BLUE}🔧 Running shared tool setup...${NC}"
            if [ -f "shared/setup-bash.sh" ]; then
                chmod +x "shared/setup-bash.sh"
                source "shared/setup-bash.sh"
            fi
            
            # Remove any bashrc created by Oh My Bash before stowing our own
            [ -f ~/.bashrc ] && rm ~/.bashrc
            
            # Stow macOS-specific dotfiles
            echo -e "${BLUE}📦 Stowing macOS dotfiles...${NC}"
            stow -t ~ macos
            ;;
            
        "devcontainer")
            echo -e "${BLUE}🐳 Setting up dev container configuration...${NC}"
            
            # Stow shared scripts
            echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
            stow -t ~ shared
            
            # Run shared bash setup for tool installation
            echo -e "${BLUE}🔧 Running shared tool setup...${NC}"
            if [ -f "shared/setup-bash.sh" ]; then
                chmod +x "shared/setup-bash.sh"
                source "shared/setup-bash.sh"
            fi
            
            # Stow devcontainer-specific configs
            if [ -d "devcontainer" ]; then
                echo -e "${BLUE}📦 Stowing devcontainer configurations...${NC}"
                stow -t ~ devcontainer
            fi
            ;;
            
        *)
            echo -e "${RED}ERROR: Unsupported platform: $PLATFORM${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Dotfiles setup complete for $PLATFORM!${NC}"
    echo -e "${BLUE}💡 Please restart your terminal or source your shell config${NC}"
}

# Run main function
main "$@" 