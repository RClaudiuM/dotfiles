#!/bin/bash
# Shared tool setup script
# This script installs Oh My Bash, fzf, and utility scripts across all platforms

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🐚 Setting up shared tools and utilities..."

# Install Oh My Bash
if [ ! -d ~/.oh-my-bash ]; then
    echo "Installing Oh My Bash..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh) --unattended" || {
        echo "ERROR: Failed to install Oh My Bash"
        exit 1
    }
    echo "✅ Oh My Bash installation completed."
else
    echo "✅ Oh My Bash is already installed"
fi

# Update OSH_THEME in .bashrc (if it exists)
if [ -f ~/.bashrc ]; then
    if grep -q '^OSH_THEME=' ~/.bashrc; then
        echo "Updating OSH_THEME to 'powerbash10k' in .bashrc"
        sed -i.bak 's/^OSH_THEME=.*/OSH_THEME="powerbash10k"/' ~/.bashrc
    else
        echo "Adding OSH_THEME to .bashrc"
        echo 'OSH_THEME="powerbash10k"' >> ~/.bashrc
    fi
fi

# Install custom theme
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/theme.sh" ]; then
    THEME_DIR=~/.oh-my-bash/themes/powerbash10k
    mkdir -p "$THEME_DIR"
    cp "$SCRIPT_DIR/theme.sh" "$THEME_DIR/powerbash10k.theme.sh"
    echo "✅ Copied custom theme to Oh My Bash"
else
    echo "⚠️  Custom theme file not found at $SCRIPT_DIR/theme.sh"
fi

# Install fzf
if [ ! -d ~/.fzf ]; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || {
        echo "ERROR: Failed to clone fzf repository"
        exit 1
    }
    ~/.fzf/install --all || {
        echo "ERROR: Failed to install fzf"
        exit 1
    }
    echo "✅ fzf installation completed."
else
    echo "✅ fzf is already installed"
fi

# Install fzf-git.sh
if [ ! -f ~/.fzf-git.sh ]; then
    echo "Installing fzf-git.sh..."
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o ~/.fzf-git.sh || {
        echo "ERROR: Failed to download fzf-git.sh"
        exit 1
    }
    echo "✅ fzf-git.sh installation completed."
else
    echo "✅ fzf-git.sh is already installed"
fi

# Make scripts executable (they are already stowed to ~/.config/scripts/)
if [ -d ~/.config/scripts ]; then
    chmod +x ~/.config/scripts/*.sh
    echo "✅ Made stowed scripts executable"
fi

echo "✅ Shared tool setup complete!"