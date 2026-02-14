{ config, ... }:

{
  homebrew = {
    enable = true;
    taps = [
      "hashicorp/tap"
      "mongodb/brew"
    ];
    brews = [
      # "awscli"
      # "corepack"
      # "exercism"
      "deno"
      "fish"
      "fzf"
      "hashicorp/tap/terraform"
      "mongodb-community"
      "postgresql@17"
      "nvm"
      "redis"
      "starship"
      "stow"
      "openssl"
      "readline"
      "sqlite3"
      "xz"
      "uv"
      "zlib"
      "tcl-tk@8"
      "pyenv"
      "gh"
      "bat"
    ];
    casks = [
      "mos"
      "font-hack-nerd-font"
      "obsidian"
      "karabiner-elements"
      "visual-studio-code"
      "mongodb-compass"
      "figma"
      "notion"
      "discord"
      "dbeaver-community"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}