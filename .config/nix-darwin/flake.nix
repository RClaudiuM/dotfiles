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

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.mkalias
        ];

        homebrew = {
        enable = true;

        brews = [
          "awscli"
          "corepack"
          "deno"
          "fish"
          "fzf"
          "hashicorp/tap/terraform"
          "mongodb/brew/mongodb-community"
          "nvm"
          "redis"
          "starship"
          "stow"
          "typescript"
        ];
        casks = [
          "font-fira-code-nerd-font"
          "mos"
          "font-hack-nerd-font"
          "obsidian"
          "karabiner-elements"
          "visual-studio-code"
          "keycombiner"
          "warp"
          "mongodb-compass"
          "microsoft-teams"
          "figma"
          "notion"
        ];
        # masApps = {
        #   "Yoink" = 457622435;
        # };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

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
          "/Applications/Visual Studio Code.app"
          "/Applications/Google Chrome.app"
          "/Applications/Slack.app"
          "/Applications/Microsoft Teams.app"
          "/Applications/Microsoft Outlook.app"
          "/Applications/MongoDB Compass.app"
          "/System/Applications/Utilities/Terminal.app"
          "/Applications/Figma.app"
          "/Applications/Obsidian.app"
          "/System/Applications/System Settings.app"
          "/Applications/Notion.app"
          "/Applications/Postman.app"
          "/Applications/Chrome Apps.localized/Google Meet.app"
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
