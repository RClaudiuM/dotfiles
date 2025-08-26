{
  description = "ClaW Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # nix-homebrew.url = "git+https://github.com/zhaofengli/nix-homebrew?ref=refs/pull/71/merge";

    # # Optional: Declarative tap management
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   # flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   # flake = false;
    # };
    # homebrew-bundle = {
    #   url = "github:homebrew/homebrew-bundle";
    #   # flake = false;
    # };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      # homebrew-core,
      # homebrew-cask,
      # homebrew-bundle,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {

          nixpkgs.config.allowUnfree = true;
          # nixpkgs.config.allowBroken = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            # pkgs.kanata
            pkgs.mkalias
            pkgs.rustup
            pkgs.awscli2
            pkgs.localsend # Config
            pkgs.raycast
            pkgs.nixfmt-rfc-style # Added nixfmt for formatting Nix files
            pkgs.brave
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
              # "typescript"
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
              # "sonar-scanner"
            ];
            casks = [
              # "font-fira-code-nerd-font"
              "mos"
              "font-hack-nerd-font"
              "obsidian"
              "karabiner-elements"
              "visual-studio-code"
              # "keycombiner"
              # "warp"
              "mongodb-compass"
              # "microsoft-teams"
              "figma"
              "notion"
              # "notion-calendar"
              "discord"
              # "affine"
              "pgadmin4"
              # "logitech-g-hub"
              # "linearmouse"
              "dbeaver-community"
              # "logi-options+"
              # "orbstack"

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
                sudo -u "${config.system.primaryUser}" /opt/homebrew/bin/brew uninstall --ignore-dependencies node || echo "Failed to uninstall Node.js"
              else
                echo "Node.js not found in Homebrew"
              fi
              echo "==============================================="
            '';
            deps = [ "users" "groups" ];
          };

          system.activationScripts.rustSetup = {
            text = ''
              echo "============= RUST INSTALLATION STARTING ==============="
              echo "Setting up Rust via rustup..."

              # Check if rustup is already initialized
              if [ ! -f "$HOME/.cargo/bin/rustc" ]; then
                echo "Installing Rust toolchain..."
                sudo -u "$USER" rustup-init -y --no-modify-path --default-toolchain stable
              else
                echo "Rust already installed, updating..."
                sudo -u "$USER" rustup update
              fi

              # Ensure default toolchain is set
              if ! sudo -u "$USER" rustup show | grep -q "^default"; then
                echo "Setting default toolchain to stable..."
                sudo -u "$USER" rustup default stable
              fi

              # Ensure .cargo/env is sourced in shell config if not already
              if ! grep -q "source \"$HOME/.cargo/env\"" "$HOME/.zshrc"; then
                echo 'source "$HOME/.cargo/env"' >> $HOME/.zshrc
              fi
              echo "============= RUST INSTALLATION COMPLETE ==============="
            '';
            # Add dependencies to ensure this runs after basic user setup but before applications
            deps = [
              "users"
              "groups"
            ];
          };

          # Deprecated
          # fonts.packages = [
          #   (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
          # ];

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
              "/Applications/Nix Apps/Brave Browser.app"
              "/Applications/Slack.app"
              "/Applications/Microsoft Teams.app"
              "/Applications/Microsoft Outlook.app"
              "/Applications/MongoDB Compass.app"
              "/System/Applications/Utilities/Terminal.app"
              "/Applications/Figma.app"
              # "/Applications/Obsidian.app"
              "/Applications/Notion.app"
              "/Applications/Postman.app"
              # "/Applications/MeetInOne.app"
              # "/Applications/Chrome Apps.localized/Google Meet.app"
              # "/System/Applications/Calendar.app"
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
          # ! Deprecated
          # services.nix-daemon.enable = true;

          nix.enable = true;
          


          # nix.package = pkgs.nix;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina
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

              # taps = {
              #   "homebrew/homebrew-core" = homebrew-core;
              #   "homebrew/homebrew-cask" = homebrew-cask;
              #   "homebrew/homebrew-bundle" = homebrew-bundle;
              # };

            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."clawMacOS".pkgs;
    };
}
