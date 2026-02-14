{
  description = "ClaW Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # nix-homebrew.url = "git+https://github.com/zhaofengli/nix-homebrew?ref=refs/pull/71/merge";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {

          nixpkgs.config.allowUnfree = true;
          # nixpkgs.config.allowBroken = true;

          # Environment variables to ensure Homebrew uses system Swift toolchain
          # This prevents conflicts between Nix Swift and system Command Line Tools Swift
          environment.variables = {
            # Point to system Command Line Tools for Swift when available
            DEVELOPER_DIR = "/Library/Developer/CommandLineTools";
          };

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            pkgs.mkalias
            pkgs.rustup
            pkgs.awscli2
            pkgs.localsend
            pkgs.raycast
            pkgs.nixfmt-rfc-style # Added nixfmt for formatting Nix files
            pkgs.brave
            pkgs.rustup
          ];

          homebrew = {
            enable = true;

            taps = [
              "hashicorp/tap"
              "mongodb/brew"
            ];

            brews = [
              # "awscli"
              # "corepack"
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
              # "exercism"
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
              # "warp"
              "mongodb-compass"
              # "microsoft-teams"
              "figma"
              "notion"
              "discord"
              # "affine"
              # "logitech-g-hub"
              "dbeaver-community"


            ];
            # masApps = {
            #   "Yoink" = 457622435;
            # };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          system.activationScripts.removeHomebrewNode = {
            text = ''
              echo "==============================================="
              echo "Checking for Homebrew Node.js installation..."
              if [ -f "/opt/homebrew/bin/node" ]; then
                echo "Node.js found, attempting to remove..."
                sudo -u "${config.system.primaryUser}" env HOME="/Users/${config.system.primaryUser}" /opt/homebrew/bin/brew uninstall --ignore-dependencies node || echo "Failed to uninstall Node.js"
              else
                echo "Node.js not found in Homebrew"
              fi
              echo "==============================================="
            '';
            # deps = [ "users" "groups" ];
          };

          system.activationScripts.nvmInstallNodeAndPnpm = {
            text = ''
              echo "==============================================="
              echo "Ensuring Node.js and pnpm via nvm/Corepack for ${config.system.primaryUser}..."
              export NVM_DIR="/Users/${config.system.primaryUser}/.nvm"
              # shellcheck disable=SC1091
              [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
              sudo -u "${config.system.primaryUser}" env HOME="/Users/${config.system.primaryUser}" NVM_DIR="$NVM_DIR" bash -c '
                source /opt/homebrew/opt/nvm/nvm.sh
                if nvm ls | grep -q "v[0-9]"; then
                  echo "Node.js already installed via nvm, skipping install."
                else
                  echo "No Node.js version found, installing latest LTS..."
                  nvm install --lts
                  nvm use --lts
                  nvm alias default lts/*
                fi
                # Ensure corepack is enabled and pnpm is available
                if command -v pnpm >/dev/null 2>&1; then
                  echo "pnpm is already available."
                else
                  echo "Enabling pnpm via corepack..."
                  corepack enable pnpm
                fi
              '
              echo "==============================================="
            '';
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
            pkgs.nerd-fonts.fira-code
            # Add other fonts as needed
          ];

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';

            system.activationScripts.fixHomebrewSwift = {
              text = ''
                echo "==============================================="
                echo "Configuring Homebrew to use system Swift..."
                # Ensure system Swift is available for Homebrew operations
                if [ -d "/Library/Developer/CommandLineTools" ]; then
                  echo "System Command Line Tools found"
                else
                  echo "Warning: Command Line Tools not found. Install with: xcode-select --install"
                fi
                echo "==============================================="
              '';
            };

            system.activationScripts.postActivation.text = ''
              ${config.system.activationScripts.removeHomebrewNode.text}
              ${config.system.activationScripts.nvmInstallNodeAndPnpm.text}
              ${config.system.activationScripts.fixHomebrewSwift.text}
            '';

          system.defaults = {
            dock.autohide = true;
            dock.orientation = "left";

            dock.magnification = true;

            dock.tilesize = 46;
            dock.largesize = 100;

            dock.persistent-apps = [
              # "${pkgs.alacritty}/Applications/Alacritty.app"
              # "${pkgs.obsidian}/Applications/Obsidian.app"
              "/System/Applications/System Settings.app"
              "/Applications/Visual Studio Code.app"
              "/Applications/Cursor.app"
              "/Applications/Nix Apps/Brave Browser.app"
              "/Applications/Slack.app"
              "/Applications/Microsoft Teams.app"
              "/Applications/Microsoft Outlook.app"
              "/Applications/MongoDB Compass.app"
              "/System/Applications/Utilities/Terminal.app"
              "/Applications/Figma.app"
              "/Applications/Notion.app"
            ];
            dock.persistent-others = [
              "/Users/claudiu.roman/Downloads"
              "/Users/claudiu.roman"
            ];
            finder.FXPreferredViewStyle = "icnv";
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
            # NSGlobalDomain.KeyRepeat = 2;

            # Trackpad/toutchpad settings
            trackpad.Clicking = true;
            NSGlobalDomain."com.apple.trackpad.forceClick" = true;
            NSGlobalDomain."com.apple.trackpad.scaling" = 3.0;
            trackpad.SecondClickThreshold = 0;
          };

          # Auto upgrade nix package and the daemon service.
          nix.enable = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true;
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;
          system.activationScripts.systemActivation.enable = true;
          system.primaryUser = "claudiu.roman";

          # Enable touch id prompt for sudo approval in the terminal
          # ! Deprecated
          # security.pam.enableSudoTouchIdAuth = true;

          security.pam.services.sudo_local.touchIdAuth = true;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # services.kanata = {
          #   enable = true;
          #   keyboards = {
          #     internalKeyboard = {
          #       devices = [
          #         "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          #         "/dev/input/by-id/usb-Framework_Laptop_16_Keyboard_Module_-_ANSI_FRAKDKEN0100000000-event-kbd"
          #         "/dev/input/by-id/usb-Framework_Laptop_16_Keyboard_Module_-_ANSI_FRAKDKEN0100000000-if02-event-kbd"
          #       ];
          #       extraDefCfg = "process-unmapped-keys yes";
          #       config = ''
          #         (defsrc
          #          caps a s d f j k l ;
          #         )
          #         (defvar
          #          tap-time 150
          #          hold-time 200
          #         )
          #         (defalias
          #          caps (tap-hold 100 100 esc lctl)
          #          a (tap-hold $tap-time $hold-time a lmet)
          #          s (tap-hold $tap-time $hold-time s lalt)
          #          d (tap-hold $tap-time $hold-time d lsft)
          #          f (tap-hold $tap-time $hold-time f lctl)
          #          j (tap-hold $tap-time $hold-time j rctl)
          #          k (tap-hold $tap-time $hold-time k rsft)
          #          l (tap-hold $tap-time $hold-time l ralt)
          #          ; (tap-hold $tap-time $hold-time ; rmet)
          #         )

          #         (deflayer base
          #          @caps @a  @s  @d  @f  @j  @k  @l  @;
          #         )
          #       '';
          #     };
          #   };
          # };

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."clawMacOS" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              # Apple Silicon Only
              enableRosetta = true;
              # User owning the Homebrew prefix
              user = "claudiu.roman";
              autoMigrate = true;
              mutableTaps = true;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."clawMacOS".pkgs;
    };
}
