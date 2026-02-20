#!/bin/bash
set -e

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
                    if [ "$DRY_RUN" = true ]; then
                        echo -e "${YELLOW}[DRY RUN] Would execute: brew install stow${NC}"
                    else
                        brew install stow
                    fi
                else
                    echo -e "${RED}ERROR: Homebrew not found. Please install Homebrew first.${NC}"
                    exit 1
                fi
                ;;
            "linux")
                if [ "$DRY_RUN" = true ]; then
                    echo -e "${YELLOW}[DRY RUN] Would execute: sudo apt-get update && sudo apt-get install -y stow${NC}"
                else
                    sudo apt-get update && sudo apt-get install -y stow
                fi
                ;;
            "arch")
                if [ "$DRY_RUN" = true ]; then
                    echo -e "${YELLOW}[DRY RUN] Would execute: sudo pacman -S --noconfirm stow${NC}"
                else
                    sudo pacman -S --noconfirm stow
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

# Install Homebrew if not present
install_homebrew() {
    if [[ "$PLATFORM" != "macos" ]]; then
        echo -e "${BLUE}🍺 Skipping Homebrew installation on non-macOS platforms${NC}"
        return 0
    fi
    
    if command_exists brew; then
        echo -e "${GREEN}✅ Homebrew already installed${NC}"
        return
    fi
    
    echo -e "${BLUE}🍺 Homebrew not found. Installing Homebrew...${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute: Homebrew install script${NC}"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for the current session (Apple Silicon vs Intel)
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        else
            echo -e "${RED}ERROR: Homebrew installed but binary not found in expected locations${NC}"
            exit 1
        fi
    fi
}

# Add common aliases to shell configs
add_common_aliases() {
    local shell_config="$1"
    
    if [ -f "$shell_config" ]; then
        echo -e "${BLUE}🔗 Adding common aliases to $(basename "$shell_config")...${NC}"
        
        # Add aliases to shell config if not already present
        if ! grep -q "alias gstu=" "$shell_config"; then
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would add alias 'gstu' to $(basename "$shell_config")${NC}"
            else
                echo "alias gstu='git stash --include-untracked'" >> "$shell_config"
                echo "✅ Added alias 'gstu' to $(basename "$shell_config")"
            fi
        fi

        if ! grep -q "alias gstaa=" "$shell_config"; then
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would add alias 'gstaa' to $(basename "$shell_config")${NC}"
            else
                echo "alias gstaa='git stash apply'" >> "$shell_config"
                echo "✅ Added alias 'gstaa' to $(basename "$shell_config")"
            fi
        fi
    fi
}

# Run shared bash setup
run_shared_bash_setup() {
    echo -e "${BLUE}🔧 Running shared tool setup...${NC}"
    if [ -f "shared/setup-bash.sh" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would execute: chmod +x shared/setup-bash.sh${NC}"
            echo -e "${YELLOW}[DRY RUN] Would source: shared/setup-bash.sh${NC}"
        else
            chmod +x "shared/setup-bash.sh"
            source "shared/setup-bash.sh"
        fi
    fi
}

# Enhance Oh My Bash .bashrc with our customizations
enhance_bashrc_template() {
    local bashrc_path="$HOME/.bashrc"
    
    if [ -f "$bashrc_path" ]; then
        echo -e "${BLUE}🔧 Enhancing $bashrc_path with custom configurations...${NC}"
        
        # Add script sourcing if not already present
        if ! grep -q "Source shared utility scripts" "$bashrc_path"; then
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would add script sourcing to $bashrc_path${NC}"
            else
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
        fi
        
        # Add our custom aliases if not present
        if ! grep -q "alias gstu=" "$bashrc_path"; then
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would add custom aliases to $bashrc_path${NC}"
            else
                cat >> "$bashrc_path" << 'EOF'

# Custom git aliases
alias gstu='git stash --include-untracked'
alias gstaa='git stash apply'
EOF
                echo "✅ Added custom aliases to $bashrc_path"
            fi
        fi
    fi
}

# macOS setup function
setup_macos() {
    echo -e "${BLUE}🍎 Setting up macOS configuration...${NC}"
    
    # Remove existing dotfiles that might conflict
    if [ "$DRY_RUN" = true ]; then
        [ -f ~/.zshrc ] && echo -e "${YELLOW}[DRY RUN] Would remove: ~/.zshrc${NC}"
        [ -f ~/.p10k.zsh ] && echo -e "${YELLOW}[DRY RUN] Would remove: ~/.p10k.zsh${NC}"
        [ -f ~/.bashrc ] && echo -e "${YELLOW}[DRY RUN] Would remove: ~/.bashrc${NC}"
    else
        [ -f ~/.zshrc ] && rm ~/.zshrc
        [ -f ~/.p10k.zsh ] && rm ~/.p10k.zsh
        [ -f ~/.bashrc ] && rm ~/.bashrc
    fi

    # Stow shared scripts first
    echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute: stow -t ~ shared${NC}"
    else
        stow -t ~ shared || true
    fi

    # Run shared bash setup for tool installation (creates Oh My Bash .bashrc)
    run_shared_bash_setup

    # If Oh My Bash created a .bashrc and we don't have one in the repo yet, copy it
    if [ -f ~/.bashrc ] && [ ! -f "macos/.bashrc" ]; then
        echo -e "${BLUE}📋 Creating macos/.bashrc from Oh My Bash template...${NC}"
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would execute: mkdir -p macos${NC}"
            echo -e "${YELLOW}[DRY RUN] Would execute: cp ~/.bashrc macos/.bashrc${NC}"
        else
            mkdir -p macos
            cp ~/.bashrc macos/.bashrc
            enhance_bashrc_template
            echo "✅ Created enhanced macos/.bashrc template"
            echo -e "${YELLOW}💡 You can now edit macos/.bashrc in your repo and run setup again${NC}"
        fi
    fi

    # Remove the generated .bashrc so we can stow our own
    if [ "$DRY_RUN" = true ]; then
        [ -f ~/.bashrc ] && echo -e "${YELLOW}[DRY RUN] Would remove: ~/.bashrc${NC}"
    else
        [ -f ~/.bashrc ] && rm ~/.bashrc
    fi

    # Stow macOS-specific dotfiles (our customized .bashrc)
    if [ -d "macos" ]; then
        echo -e "${BLUE}📦 Stowing macOS dotfiles...${NC}"
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would execute: stow -t ~ macos${NC}"
        else
            stow -t ~ macos || true
        fi
    fi

    # Add common aliases to .bashrc
    add_common_aliases ~/.bashrc
    
    # Run macOS-specific setup (Nix + nix-darwin)
    if [ -f "macos/setup.sh" ]; then
        echo -e "${BLUE}🔧 Running macOS-specific setup (Nix + nix-darwin)...${NC}"
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would execute: chmod +x macos/setup.sh${NC}"
            echo -e "${YELLOW}[DRY RUN] Would execute: ./macos/setup.sh --dry-run${NC}"
            # Still call it in dry-run mode to show what would happen
            chmod +x macos/setup.sh
            ./macos/setup.sh --dry-run
        else
            chmod +x macos/setup.sh
            ./macos/setup.sh
        fi
    fi
}

# Devcontainer setup function
setup_devcontainer() {
    echo -e "${BLUE}🐳 Setting up dev container configuration...${NC}"
    
    # Run shared bash setup for tool installation (creates Oh My Bash .bashrc)
    run_shared_bash_setup

    echo -e "${BLUE}📋 Copying shared scripts from shared/.config/scripts...${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute: mkdir -p ~/.config/scripts${NC}"
        [ -d "shared/.config/scripts" ] && echo -e "${YELLOW}[DRY RUN] Would execute: cp shared/.config/scripts/*.sh ~/.config/scripts/${NC}"
    else
        mkdir -p ~/.config/scripts
        if [ -d "shared/.config/scripts" ]; then
            cp shared/.config/scripts/*.sh ~/.config/scripts/
        fi
    fi

    # Enhance the generated .bashrc with customizations
    enhance_bashrc_template

    # Add common aliases to .bashrc
    add_common_aliases ~/.bashrc
}



# Main installation function
main() {
    echo -e "${BLUE}Platform detected: $PLATFORM${NC}"
    
    # Install stow and Homebrew first
    install_homebrew
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