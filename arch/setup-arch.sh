#!/bin/bash
set -e

# Arch Linux setup function (modularized)
setup_arch() {
    echo -e "${BLUE}🏗️  Setting up Arch Linux configuration...${NC}"

    # Run shared bash setup first (creates Oh My Bash .bashrc)
    run_shared_bash_setup

    # If Oh My Bash created a .bashrc and we don't have one in the repo yet, copy it
    if [ -f ~/.bashrc ] && [ ! -f "arch/.bashrc" ]; then
        echo -e "${BLUE}📋 Creating arch/.bashrc from Oh My Bash template...${NC}"
        mkdir -p arch
        cp ~/.bashrc arch/.bashrc
        enhance_bashrc_template
        echo "✅ Created enhanced arch/.bashrc template"
        echo -e "${YELLOW}💡 You can now edit arch/.bashrc in your repo and run setup again${NC}"
    fi

    # Remove the generated .bashrc so we can stow our own
    [ -f ~/.bashrc ] && rm ~/.bashrc

    # Stow shared scripts
    echo -e "${BLUE}📦 Stowing shared configurations...${NC}"
    stow -t ~ shared

    # Stow arch-specific dotfiles (our customized .bashrc)
    if [ -d "arch" ]; then
        echo -e "${BLUE}📦 Stowing Arch dotfiles...${NC}"
        stow --adopt -t ~ arch
    fi

    # Add common aliases to .bashrc
    add_common_aliases ~/.bashrc

    # Install additional packages for Hyprland setup
    echo -e "${BLUE}📦 Installing Hyprland and related packages...${NC}"
    sudo pacman -S --noconfirm hyprland hyprpaper waybar wofi hyprpaper
    echo -e "${GREEN}✅ Hyprland and related packages installed!${NC}"
}
