{
  description = "ClaW NixOS system flake for Arch replacement";

  # Input sources - where we get our packages and modules from
  inputs = {
    # Main package repository - using unstable for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Hardware configuration helper (optional but useful)
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # Output configurations - what this flake produces
  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs: {
    
    # System configurations - replace "your-hostname" with your actual hostname
    nixosConfigurations.nixos-desktop = nixpkgs.lib.nixosSystem {
      # System architecture (change to x86_64-linux if using Intel/AMD)
      system = "x86_64-linux";
      
      # Configuration modules to include
      modules = [
        # Main configuration file
        ./configuration.nix
        
        # Hardware-specific optimizations (optional)
        # nixos-hardware.nixosModules.common-pc-ssd
        # nixos-hardware.nixosModules.common-gpu-nvidia  # if you have NVIDIA
        
        # Make inputs available to configuration.nix
        {
          _module.args = { inherit inputs; };
        }
      ];
    };
  };
}
