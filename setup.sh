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

# Run shared bash setup
run_shared_bash_setup() {
    echo -e "${BLUE}🔧 Running shared tool setup...${NC}"
    if [ -f "shared/setup-bash.sh" ]; then
        chmod +x "shared/setup-bash.sh"
        source "shared/setup-bash.sh"
    fi
}

# Enhance Oh My Bash .bashrc with our customizations
enhance_bashrc_template() {
    local bashrc_path="$HOME/.bashrc"
    
    if [ -f "$bashrc_path" ]; then
        echo -e "${BLUE}🔧 Enhancing $bashrc_path with custom configurations...${NC}"
        
        # Add script sourcing if not already present
        if ! grep -q "Source shared utility scripts" "$bashrc_path"; then
            cat >> "$bashrc_path" << 'EOF'

# Source shared utility scripts
for script in ~/.config/scripts/*.sh; do
    [ -f "$script" ] && source "$script"
done

# Source fzf integration
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.fzf-git.sh ] && source ~/.fzf-git.sh
EOF
            echo "✅ Added script sourcing to $bashrc_path"
        fi
        
        # Add our custom aliases if not present
        if ! grep -q "alias gstu=" "$bashrc_path"; then
            cat >> "$bashrc_path" << 'EOF'

# Custom git aliases
alias gstu='git stash --include-untracked'
alias gstaa='git stash apply'
EOF
            echo "✅ Added custom aliases to $bashrc_path"
        fi
    fi
}

# macOS setup function
setup_macos() {
    echo -e "${BLUE}🍎 Setting up macOS configuration...${NC}"
    
    # Remove existing dotfiles that might conflict
    [ -f ~/.zshrc ] && rm ~/.zshrc
    [ -f ~/.p10k.zsh ] && rm ~/.p10k.zsh
    [ -f ~/.bashrc ] && rm ~/.bashrc

    # Stow shared scripts first
    echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
    stow -t ~ shared

    # Run shared bash setup for tool installation (creates Oh My Bash .bashrc)
    run_shared_bash_setup

    # If Oh My Bash created a .bashrc and we don't have one in the repo yet, copy it
    if [ -f ~/.bashrc ] && [ ! -f "macos/.bashrc" ]; then
        echo -e "${BLUE}📋 Creating macos/.bashrc from Oh My Bash template...${NC}"
        mkdir -p macos
        cp ~/.bashrc macos/.bashrc
        enhance_bashrc_template
        echo "✅ Created enhanced macos/.bashrc template"
        echo -e "${YELLOW}💡 You can now edit macos/.bashrc in your repo and run setup again${NC}"
    fi

    # Remove the generated .bashrc so we can stow our own
    [ -f ~/.bashrc ] && rm ~/.bashrc

    # Stow macOS-specific dotfiles (our customized .bashrc)
    if [ -d "macos" ]; then
        echo -e "${BLUE}📦 Stowing macOS dotfiles...${NC}"
        stow -t ~ macos
    fi

    # Add common aliases to .bashrc
    add_common_aliases ~/.bashrc
}

# Devcontainer setup function
setup_devcontainer() {
    echo -e "${BLUE}🐳 Setting up dev container configuration...${NC}"
    
    # Run shared bash setup for tool installation (creates Oh My Bash .bashrc)
    run_shared_bash_setup

    echo -e "${BLUE}📋 Copying shared scripts from shared/.config/scripts...${NC}"
    mkdir -p ~/.config/scripts
    if [ -d "shared/.config/scripts" ]; then
        cp shared/.config/scripts/*.sh ~/.config/scripts/
    fi

    # Enhance the generated .bashrc with customizations
    enhance_bashrc_template

    # Add common aliases to .bashrc
    add_common_aliases ~/.bashrc
}



# Main installation function
main() {
    echo -e "${BLUE}Platform detected: $PLATFORM${NC}"
    
    # Install stow first
    install_stow
    
    # Platform-specific setup
    case $PLATFORM in
        "macos")
            setup_macos
            ;;
        "devcontainer")
            setup_devcontainer
            ;;
        "arch")
            # Source and call the modularized arch setup
            if [ -f "arch/setup-arch.sh" ]; then
                source arch/setup-arch.sh
                setup_arch
            else
                echo -e "${RED}ERROR: arch/setup-arch.sh not found!${NC}"
                exit 1
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