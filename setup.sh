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
        elif [ -f /etc/nixos/configuration.nix ] || command -v nixos-rebuild >/dev/null 2>&1; then
            echo "nixos"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
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
    if [[ "$PLATFORM" == "devcontainer" ]]; then
        echo -e "${BLUE}📦 Skipping stow installation in devcontainer (using direct file copying)${NC}"
        return 0
    fi
    
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
            "linux")
                sudo apt-get update && sudo apt-get install -y stow
                ;;
            "arch")
                sudo pacman -S --noconfirm stow
                ;;
            "nixos")
                # NixOS should have stow from configuration.nix
                echo -e "${YELLOW}⚠️  Stow should be installed via NixOS configuration${NC}"
                if ! command_exists stow; then
                    nix-shell -p stow --run "echo 'Using stow from nix-shell'"
                fi
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

# Add common aliases to shell configs
add_common_aliases() {
    local shell_config="$1"
    
    if [ -f "$shell_config" ]; then
        echo -e "${BLUE}🔗 Adding common aliases to $(basename "$shell_config")...${NC}"
        
        # Add aliases to shell config if not already present
        if ! grep -q "alias gstu=" "$shell_config"; then
            echo "alias gstu='git stash --include-untracked'" >> "$shell_config"
            echo "✅ Added alias 'gstu' to $(basename "$shell_config")"
        fi

        if ! grep -q "alias gstaa=" "$shell_config"; then
            echo "alias gstaa='git stash apply'" >> "$shell_config"
            echo "✅ Added alias 'gstaa' to $(basename "$shell_config")"
        fi
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
            
            # Add common aliases to .bashrc
            add_common_aliases ~/.bashrc
            ;;
            
        "devcontainer")
            echo -e "${BLUE}🐳 Setting up dev container configuration...${NC}"
            
            # Run shared bash setup for tool installation
            echo -e "${BLUE}� Running shared tool setup...${NC}"
            if [ -f "shared/setup-bash.sh" ]; then
                chmod +x "shared/setup-bash.sh"
                source "shared/setup-bash.sh"
            fi
            
            # Copy shared scripts to accessible location instead of stowing
            echo -e "${BLUE}� Setting up shared scripts...${NC}"
            mkdir -p ~/.config/scripts
            if [ -d "shared/.config/scripts" ]; then
                cp -r shared/.config/scripts/* ~/.config/scripts/
                chmod +x ~/.config/scripts/*.sh
                echo "✅ Copied shared scripts to ~/.config/scripts"
            fi
            
            # Copy fzf config if it exists
            if [ -d "shared/.config/fzf" ]; then
                mkdir -p ~/.config/fzf
                cp -r shared/.config/fzf/* ~/.config/fzf/
                echo "✅ Copied fzf configuration"
            fi
            
            
            # Source the shared configs in the shell configs
            echo -e "${BLUE}� Setting up shell integration...${NC}"
            
            # Add sourcing to .bashrc if it exists
            if [ -f ~/.bashrc ]; then
                echo "" >> ~/.bashrc
                echo "# Source shared utility scripts" >> ~/.bashrc
                cat >> ~/.bashrc << 'EOF'
for script in ~/.config/scripts/*.sh; do
    [ -f "$script" ] && source "$script"
done
EOF
                echo "✅ Added script sourcing to .bashrc"
            fi
            
            # Add sourcing to .zshrc if it exists  
            if [ -f ~/.zshrc ]; then
                echo "" >> ~/.zshrc
                echo "# Source shared utility scripts" >> ~/.zshrc
                cat >> ~/.zshrc << 'EOF'
for script in ~/.config/scripts/*.sh; do
    [ -f "$script" ] && source "$script"
done
EOF
                echo "✅ Added script sourcing to .zshrc"
            fi
            
            # Add common aliases to .bashrc
            add_common_aliases ~/.bashrc
            ;;
            
        "nixos")
            echo -e "${BLUE}❄️  Setting up NixOS configuration...${NC}"
            echo -e "${YELLOW}💡 For initial NixOS setup, run: ./archNixOS/setup.sh${NC}"
            
            # Stow shared scripts
            echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
            stow -t ~ shared
            
            # Run shared bash setup for tool installation
            echo -e "${BLUE}🔧 Running shared tool setup...${NC}"
            if [ -f "shared/setup-bash.sh" ]; then
                chmod +x "shared/setup-bash.sh"
                source "shared/setup-bash.sh"
            fi
            
            # Add common aliases to .bashrc
            add_common_aliases ~/.bashrc
            ;;
            
        "arch")
            echo -e "${BLUE}🏗️  Setting up Arch Linux configuration...${NC}"
            
            # Stow shared scripts
            echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
            stow -t ~ shared
            
            # Run shared bash setup for tool installation
            echo -e "${BLUE}🔧 Running shared tool setup...${NC}"
            if [ -f "shared/setup-bash.sh" ]; then
                chmod +x "shared/setup-bash.sh"
                source "shared/setup-bash.sh"
            fi
            
            # Add common aliases to .bashrc
            add_common_aliases ~/.bashrc
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