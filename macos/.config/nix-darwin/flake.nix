{
  description = "ClaW Darwin system flake";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
      # nix-homebrew.url = "git+https://github.com/zhaofengli/nix-homebrew?ref=refs/pull/71/merge";
  };
  
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;
        
        environment.variables = {
          DEVELOPER_DIR = "/Library/Developer/CommandLineTools";
        };
        
        environment.systemPackages = with pkgs; [
          vim
          mkalias
          rustup
          awscli2
          localsend
          raycast
          nixfmt-rfc-style
          brave
        ];
        
        fonts.packages = with pkgs.nerd-fonts; [
          jetbrains-mono
          fira-code
        ];
        
        nix = {
          enable = true;
          settings.experimental-features = "nix-command flakes";
        };
        
        programs.zsh.enable = true;
        
        system = {
          configurationRevision = self.rev or self.dirtyRev or null;
          stateVersion = 5;
          activationScripts.systemActivation.enable = true;
          primaryUser = "claudiu.roman";
        };
        
        security.pam.services.sudo_local.touchIdAuth = true;
        
        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        
        imports = [
          ./modules/activation-scripts.nix
          ./modules/homebrew.nix
          ./modules/system-defaults.nix
        ];
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#clawMacOS
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