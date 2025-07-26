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

# Function to check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ This script should not be run as root!${NC}"
        echo -e "${YELLOW}💡 Run as your regular user, we'll ask for sudo when needed${NC}"
        exit 1
    fi
}

# Function to install Nix if not present
install_nix() {
    if ! command_exists nix; then
        echo -e "${BLUE}📦 Installing Nix package manager...${NC}"
        
        # Install Nix using the determinate installer (more reliable)
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        
        # Source the nix environment
        if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        
        echo -e "${GREEN}✅ Nix installation completed${NC}"
        echo -e "${YELLOW}💡 You may need to restart your shell or source your profile${NC}"
    else
        echo -e "${GREEN}✅ Nix is already installed${NC}"
    fi
}

# Function to enable systemd service for Nix daemon
enable_nix_daemon() {
    echo -e "${BLUE}🔧 Enabling Nix daemon service...${NC}"
    
    if ! systemctl is-enabled nix-daemon.service >/dev/null 2>&1; then
        sudo systemctl enable nix-daemon.service
        echo -e "${GREEN}✅ Nix daemon service enabled${NC}"
    else
        echo -e "${GREEN}✅ Nix daemon service already enabled${NC}"
    fi
    
    if ! systemctl is-active nix-daemon.service >/dev/null 2>&1; then
        sudo systemctl start nix-daemon.service
        echo -e "${GREEN}✅ Nix daemon service started${NC}"
    else
        echo -e "${GREEN}✅ Nix daemon service already running${NC}"
    fi
}

# Function to setup hardware configuration
setup_hardware_config() {
    local config_dir="$(dirname "$0")/.config/nix"
    
    echo -e "${BLUE}🔧 Setting up hardware configuration...${NC}"
    
    if [ ! -f "$config_dir/hardware-configuration.nix" ]; then
        echo -e "${YELLOW}⚠️  No hardware-configuration.nix found${NC}"
        echo -e "${BLUE}📋 Generating hardware configuration...${NC}"
        
        # Generate hardware configuration
        sudo nixos-generate-config --root / --dir "$config_dir"
        
        # Move the generated configuration.nix to a backup since we have our own
        if [ -f "$config_dir/configuration.nix.bak" ]; then
            mv "$config_dir/configuration.nix" "$config_dir/configuration-generated.nix.bak"
        fi
        
        echo -e "${GREEN}✅ Hardware configuration generated${NC}"
    else
        echo -e "${GREEN}✅ Hardware configuration already exists${NC}"
    fi
}

# Function to update system hostname in configuration
update_hostname() {
    local config_dir="$(dirname "$0")/.config/nix"
    local current_hostname=$(hostname)
    
    echo -e "${BLUE}🏷️  Updating hostname configuration...${NC}"
    echo -e "${BLUE}Current hostname: ${YELLOW}$current_hostname${NC}"
    
    # Ask user if they want to change the hostname in the config
    read -p "Do you want to update the hostname in configuration.nix to '$current_hostname'? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i.bak "s/hostName = \"nixos-desktop\";/hostName = \"$current_hostname\";/" "$config_dir/configuration.nix"
        echo -e "${GREEN}✅ Hostname updated to $current_hostname${NC}"
    else
        echo -e "${YELLOW}💡 Keeping original hostname configuration${NC}"
    fi
}

# Function to update username in configuration
update_username() {
    local config_dir="$(dirname "$0")/.config/nix"
    local current_user=$(whoami)
    
    echo -e "${BLUE}👤 Updating username configuration...${NC}"
    echo -e "${BLUE}Current user: ${YELLOW}$current_user${NC}"
    
    # Ask user if they want to change the username in the config
    read -p "Do you want to update the username in configuration.nix to '$current_user'? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i.bak "s/users.users.claudiu/users.users.$current_user/" "$config_dir/configuration.nix"
        echo -e "${GREEN}✅ Username updated to $current_user${NC}"
    else
        echo -e "${YELLOW}💡 Keeping original username configuration${NC}"
    fi
}

# Function to copy flake configuration to /etc/nixos
setup_nixos_config() {
    local config_dir="$(dirname "$0")/.config/nix"
    
    echo -e "${BLUE}📋 Setting up NixOS configuration...${NC}"
    
    # Create backup of existing configuration if it exists
    if [ -f /etc/nixos/configuration.nix ]; then
        sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
        echo -e "${GREEN}✅ Backed up existing configuration${NC}"
    fi
    
    # Copy our configuration files
    sudo cp "$config_dir/configuration.nix" /etc/nixos/
    sudo cp "$config_dir/flake.nix" /etc/nixos/
    
    # Copy hardware configuration if it exists locally
    if [ -f "$config_dir/hardware-configuration.nix" ]; then
        sudo cp "$config_dir/hardware-configuration.nix" /etc/nixos/
    fi
    
    echo -e "${GREEN}✅ NixOS configuration copied to /etc/nixos${NC}"
}

# Function to apply NixOS configuration
apply_nixos_config() {
    echo -e "${BLUE}🚀 Applying NixOS configuration...${NC}"
    echo -e "${YELLOW}⚠️  This may take a while on first run...${NC}"
    
    # Change to /etc/nixos for the rebuild
    cd /etc/nixos
    
    # Apply the configuration using the flake
    sudo nixos-rebuild switch --flake .#nixos-desktop --show-trace
    
    echo -e "${GREEN}✅ NixOS configuration applied successfully!${NC}"
}

# Function to setup dotfiles integration
setup_dotfiles() {
    echo -e "${BLUE}📁 Setting up dotfiles integration...${NC}"
    
    # Install stow if not present (should be installed via NixOS config now)
    if ! command_exists stow; then
        echo -e "${YELLOW}⚠️  Installing stow temporarily...${NC}"
        nix-shell -p stow --run "echo 'Stow available in this shell'"
    fi
    
    # Create symlinks for shared configurations
    local dotfiles_dir="$(dirname "$(dirname "$0")")"
    
    if [ -d "$dotfiles_dir/shared" ]; then
        echo -e "${BLUE}🔗 Stowing shared configurations...${NC}"
        cd "$dotfiles_dir"
        stow -t ~ shared
        echo -e "${GREEN}✅ Shared configurations stowed${NC}"
    fi
    
    # Make scripts executable
    if [ -d ~/.config/scripts ]; then
        chmod +x ~/.config/scripts/*.sh
        echo -e "${GREEN}✅ Made scripts executable${NC}"
    fi
}

# Function to install Oh My Bash/Zsh
setup_shell() {
    echo -e "${BLUE}🐚 Setting up shell environment...${NC}"
    
    # Run shared bash setup if available
    local dotfiles_dir="$(dirname "$(dirname "$0")")"
    local setup_bash="$dotfiles_dir/shared/setup-bash.sh"
    
    if [ -f "$setup_bash" ]; then
        echo -e "${BLUE}🔧 Running shared shell setup...${NC}"
        chmod +x "$setup_bash"
        bash "$setup_bash"
    else
        echo -e "${YELLOW}⚠️  Shared shell setup not found${NC}"
    fi
}

# Function to show post-installation instructions
show_post_install() {
    echo -e "\n${GREEN}🎉 NixOS setup completed successfully!${NC}\n"
    
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo -e "  1. ${YELLOW}Reboot your system${NC} to ensure all changes take effect"
    echo -e "  2. ${YELLOW}Check that all services are running${NC}:"
    echo -e "     ${BLUE}systemctl status nix-daemon${NC}"
    echo -e "  3. ${YELLOW}Test your shell configuration${NC}:"
    echo -e "     ${BLUE}source ~/.zshrc${NC} (or restart terminal)"
    echo -e "  4. ${YELLOW}Update your system regularly${NC}:"
    echo -e "     ${BLUE}sudo nixos-rebuild switch --flake /etc/nixos#nixos-desktop${NC}"
    
    echo -e "\n${BLUE}💡 Useful commands:${NC}"
    echo -e "  • ${BLUE}nixos-rebuild switch --flake /etc/nixos#nixos-desktop${NC} - Apply config changes"
    echo -e "  • ${BLUE}nix-collect-garbage -d${NC} - Clean up old generations"
    echo -e "  • ${BLUE}nixos-option system.stateVersion${NC} - Check system version"
    
    echo -e "\n${GREEN}🔧 Configuration files:${NC}"
    echo -e "  • ${BLUE}/etc/nixos/configuration.nix${NC} - Main system configuration"
    echo -e "  • ${BLUE}/etc/nixos/flake.nix${NC} - Flake configuration"
    echo -e "  • ${BLUE}/etc/nixos/hardware-configuration.nix${NC} - Hardware-specific settings"
    
    echo -e "\n${YELLOW}⚠️  Remember to edit the configuration files to match your preferences!${NC}"
}

# Main function
main() {
    echo -e "${GREEN}🚀 Starting NixOS setup...${NC}"
    
    # Pre-flight checks
    check_not_root
    
    # Confirm before proceeding
    echo -e "${YELLOW}⚠️  This script will:${NC}"
    echo -e "  • Install Nix (if needed)"
    echo -e "  • Generate hardware configuration"
    echo -e "  • Apply NixOS configuration from flake"
    echo -e "  • Set up dotfiles and shell environment"
    echo -e ""
    read -p "Do you want to continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Setup cancelled${NC}"
        exit 0
    fi
    
    # Installation steps
    install_nix
    enable_nix_daemon
    setup_hardware_config
    update_hostname
    update_username
    setup_nixos_config
    apply_nixos_config
    setup_dotfiles
    setup_shell
    
    # Show completion message
    show_post_install
}

# Run main function
main "$@"
