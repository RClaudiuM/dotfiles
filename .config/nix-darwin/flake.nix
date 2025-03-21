{
  description = "ClaW Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;
      # nixpkgs.config.allowBroken = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          # pkgs.kanata
          pkgs.mkalias
          # pkgs.gh
        ];

        homebrew = {
        enable = true;
        brews = [
          "awscli"
          # "corepack"
          "deno"
          "fish"
          "fzf"
          "hashicorp/tap/terraform"
          "mongodb/brew/mongodb-community"
          "nvm"
          "redis"
          "starship"
          "stow"
          # "typescript"
          "openssl"
          "readline"
          "sqlite3"
          "xz"
          "zlib"
          "tcl-tk@8"
          "pyenv"
          "gh"
          "bat"
          "sonar-scanner"
        ];
        casks = [
          "font-fira-code-nerd-font"
          "mos"
          "font-hack-nerd-font"
          "obsidian"
          "karabiner-elements"
          "visual-studio-code"
          "keycombiner"
          # "warp"
          "mongodb-compass"
          "microsoft-teams"
          "figma"
          "notion"
          "discord"
          "affine"
          # "logi-options+"
        ];
        # masApps = {
        #   "Yoink" = 457622435;
        # };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Add this section before the homebrew configuration
      system.activationScripts.preActivation.text = ''
        echo "Removing Homebrew Node.js installation..."
        if [ -f "/opt/homebrew/bin/node" ]; then
          /opt/homebrew/bin/brew uninstall --ignore-dependencies node || true
        fi
      '';


      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      system.activationScripts.applications.text = let
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
          while read src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';


      system.defaults = {
        dock.autohide  = true;
        dock.orientation = "left";

        dock.magnification = true;

        dock.tilesize = 46;
        dock.largesize = 100;

        dock.persistent-apps = [
          # "${pkgs.alacritty}/Applications/Alacritty.app"
          # "${pkgs.obsidian}/Applications/Obsidian.app"
          "/System/Applications/System Settings.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Google Chrome.app"
          "/Applications/Slack.app"
          "/Applications/Microsoft Teams.app"
          "/Applications/Microsoft Outlook.app"
          "/Applications/MongoDB Compass.app"
          "/System/Applications/Utilities/Terminal.app"
          "/Applications/Figma.app"
          "/Applications/Obsidian.app"
          "/Applications/Notion.app"
          "/Applications/Postman.app"
          "/Applications/MeetInOne.app"
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
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # Enable touch id propmpt for sudo approval in the terminal
      security.pam.enableSudoTouchIdAuth = true;

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
          };
        }
         ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."clawMacOS".pkgs;
  };
}
