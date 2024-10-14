# My dotfiles

In order to be able to conveniently manage my dotfiles i've decided that they will from now on live on this repository inside GitHub.

With the help of [STOW](https://www.gnu.org/software/stow/) i can apply them nicely in my machine

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
- [nvm](https://formulae.brew.sh/formula/nvm#default) - [node version manager ](https://github.com/nvm-sh/nvm)
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
brew tap hashicorp/tap mongodb/brew homebrew/cask-fonts
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

## Dotfiles installation

First, check out the dotfiles repo in your $HOME directory using git

```bash
git clone https://github.com/RClaudiuM/dotfiles.git
cd dotfiles
```

then use GNU stow to create symlinks

```bash
stow .
```
