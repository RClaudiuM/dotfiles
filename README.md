[TOC]

# Cross-Platform Dotfiles

Cross-platform dotfiles management with **GNU Stow** and **platform detection**. One repository for all my development environments:

- 🍎 **macOS** (nix-darwin + Homebrew)
- 🐳 **Dev Containers** (lightweight setup)
- **Arch Linux / NixOS** coming soon.... i hope

## Quick Setup

**One command works everywhere:**

```bash
git clone https://github.com/RClaudiuM/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

The script will:

1. 🔍 **Auto-detect your platform** (macOS/DevContainer)
2. 📦 **Install GNU Stow** if needed
3. 🔗 **Stow shared configurations** (scripts, fzf config)
4. 🛠️ **Install shared tools** (Oh My Bash, fzf, custom scripts)
5. ⚙️ **Stow platform-specific configs** (.zshrc, .p10k.zsh, etc.)
6. 🚀 **Run platform-specific setup** (nix-darwin on macOS)

## Repository Structure

```
dotfiles/
├── setup.sh                    # Universal setup script
├── shared/                     # Shared across all platforms
│   ├── .config/
│   │   ├── scripts/            # Custom shell scripts
│   │   └── fzf                 # fzf configuration
│   ├── setup-bash.sh          # Tool installer (Oh My Bash, fzf, etc.)
│   └── theme.sh               # Oh My Bash theme
├── macos/                     # macOS-specific configs
│   ├── .zshrc                 # macOS zsh configuration
│   ├── .p10k.zsh             # Powerlevel10k config
│   ├── .bash_profile         # macOS bash profile
│   ├── .config/
│   │   ├── nix-darwin/       # nix-darwin configuration
│   │   ├── karabiner/        # Keyboard remapping
│   │   ├── fish/             # Fish shell config
│   │   └── gh/               # GitHub CLI config
│   └── setup.sh              # macOS-specific setup
└── devcontainer/              # Dev container configs
    ├── .zshrc                 # Container-optimized zsh
    └── setup.sh               # Container-specific setup
```

---

## Manual Platform Setup

If you prefer to run platform-specific setup manually:

### macOS

```bash
stow shared macos
source shared/setup-bash.sh
source macos/setup.sh
```

### Dev Container

```bash
stow shared devcontainer
source shared/setup-bash.sh
```

---

## Git installation

You will need git installed by your preferred method ( MAC already had it installed by default )

## Install Oh My Zsh

You can install Oh My Zsh by running the following command in your terminal

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Install Homebrew

You can install Homebrew by running the following command in your terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

or check the [Homebrew website](https://brew.sh/) for more information

## Install Homebrew packages and casks

For a web developer environment you will need some packages and casks installed via Homebrew

Packages like:

- [awscli](https://formulae.brew.sh/formula/awscli#default) - aws management cli
- [corepack](https://formulae.brew.sh/formula/corepack) - used for managing npm packages and installing yarn
- [deno](https://formulae.brew.sh/formula/deno#default) - runtime for TypeScript and JavaScript
- [fish](https://formulae.brew.sh/formula/fish#default) - modern terminal, check it out [here](https://fishshell.com/)
- [fzf](https://formulae.brew.sh/formula/fzf#default) - fuzzy finder for terminals, check it out [here](https://github.com/junegunn/fzf)
- [terraform](https://developer.hashicorp.com/terraform)
- [mongodb-community](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/#installing-mongodb-8.0-edition-edition) - mongodb server ( will require starting the service )
- [nvm](https://formulae.brew.sh/formula/nvm#default) - [node version manager](https://github.com/nvm-sh/nvm)
- [redis](https://formulae.brew.sh/formula/redis#default) - redis server ( will require starting the service )
- [starship](https://formulae.brew.sh/formula/starship#default) - cross-shell prompt
- [stow](https://formulae.brew.sh/formula/stow#default) - symlink manager, this what we will use to manage the dotfiles, check more [here](https://www.gnu.org/software/stow/manual/stow.html)
- [typescript](https://formulae.brew.sh/formula/typescript#default) - TypeScript compiler

and casks like:

- google-chrome - browser
- [visual-studio-code](https://formulae.brew.sh/cask/visual-studio-code)
- font-fira-code-nerd-font - font for terminal and code editor
- font-hack-nerd-font
- mongodb-compass - mongodb client
- mos - a mouse smooth scrolling app
- warp - a modern terminal emulator
- obsidian - a note-taking app
- figma - a design tool

### Brew taps

Before installing all the packages and casks you will need to tap some repositories

```bash
brew tap hashicorp/tap mongodb/brew
```

### Install Brew packages and casks

To install all those you will need to run

```bash
brew install awscli corepack deno fish fzf terraform mongodb-community nvm redis starship stow typescript
```

and for casks

```bash
brew install --cask google-chrome visual-studio-code font-fira-code-nerd-font font-hack-nerd-font mongodb-compass mos warp obsidian figma
```

## Start services

After installing mongodb and redis you will need to start the services

```bash
brew services start mongodb-community
```

and

```bash
brew services start redis
```

## Quick mongodb backup and restore

### Exporting and importing connections

Mongodb connections can be restored by exporting the connections from the mongodb compass app following [this guide](https://www.mongodb.com/docs/compass/current/connect/favorite-connections/import-export-ui/export/#procedure)

### Exporting and importing databases

For this you will need [MongoDB Command Line Database Tools](https://www.mongodb.com/try/download/database-tools)

A full local database can be exported using the following command

```bash
 mongodump --host localhost:27017  --out  ~/Desktop/mongo-migration
```

The above command will export the database to the Desktop in a folder called mongo-migration

Then after exporting the database you will need to copy it to the new machine's desktop and run the following command

```bash
mongorestore ~/Desktop/mongo-migration/ --host 127.0.0.1:27017
```

### Mongodb config file and data directory locations

https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/#installing-mongodb-8.0-edition-edition

## Dotfiles installation

**Quick Setup (Recommended):**

```bash
git clone https://github.com/RClaudiuM/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

**Manual Setup:**

First, check out the dotfiles repo in your $HOME directory using git

```bash
git clone https://github.com/RClaudiuM/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

then use GNU stow to create symlinks based on your platform:

For macOS:

```bash
stow shared macos
```

For dev containers:

```bash
stow shared devcontainer
```

# Using Nix and nix-darwin to spin up dev environments {#using-nix}

## What is Nix?

Nix is a package manager that is used to manage packages and environments in a functional way. It is used to manage dependencies and environments in a declarative way.

More details on their official [website](https://nixos.org/)

## What is nix-darwin?

`nix-darwin` is a module that is used to manage the configuration of a machine using nix. It is used to manage the configuration of the machine in a declarative way.

## Install Nix

You can install Nix by following the instructions on their official [website](https://nixos.org/download/#nix-install-macos)

or by running the following command in your terminal

```bash
sh <(curl -L https://nixos.org/nix/install)
```

The installation is pretty straightforward and you can check what it actually does [here](https://nix.dev/manual/nix/2.18/installation/installing-binary#macos-installation)

## Verify the installation

After you have installed Nix, restart your terminal/shell and run the following command to verify the installation:

```bash
nix-shell -p neofetch --run neofetch
```

## Update user profile

In the [flake config file](macos/.config/nix-darwin/flake.nix) you will need to rename the user set in the file to your current user.

## Running the flake

You can run the flake by running the following command in your terminal

```bash
nix run nix-darwin --experimental-features "nix-command flakes" -- switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS
```

## Verify darwin

If the above command ran successfully you can verify the installation by running the following command

```bash
which darwin-rebuild
```

If that outputs a path to the darwin-rebuild command then you are good to go.

## Update the flake

You can now update the flake config to your liking be installing packages and managing settings straight from the flake file.

Once you're ready to apply the changes you can run the following command

```bash
sudo darwin-rebuild switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS --verbose
```

**Note:** Recent versions of nix-darwin require sudo and the full flake path with configuration name.

## Nix packages and settings

You can find more information about nix packages and settings on the following [website](https://mynixos.com/nixpkgs).

# Tips and tricks

TBD...
