{ config, pkgs, lib, inputs, ... }:

{
  # ============================================================================
  # IMPORTS - Additional configuration modules
  # ============================================================================
  imports = [
    # Hardware configuration (generated during installation)
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # BOOT CONFIGURATION - How the system starts
  # ============================================================================
  boot.loader = {
    # Use systemd-boot instead of GRUB (modern UEFI systems)
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ============================================================================
  # NETWORKING - Network and hostname configuration
  # ============================================================================
  networking = {
    hostName = "claw"; # Change this to your preferred hostname
    networkmanager.enable = true; # Easy wireless configuration
    
    # Firewall configuration
    # firewall = {
    #   enable = true;
    #   # allowedTCPPorts = [ 22 80 443 3000 ]; # Add ports you need
    # };
  };

  # ============================================================================
  # LOCALIZATION - Time zone, keyboard, language
  # ============================================================================
  time.timeZone = "Europe/Bucharest"; # Change to your timezone
  
  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ============================================================================
  # DESKTOP ENVIRONMENT - GUI and display configuration
  # ============================================================================
  # Enable X11 windowing system
  services.xserver = {
    enable = true;
    
    # Desktop environment (choose one)
    displayManager.gdm.enable = true;      # GNOME display manager
    desktopManager.gnome.enable = true;    # GNOME desktop
    
    # Alternative: KDE Plasma
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # ============================================================================
  # AUDIO - Sound configuration
  # ============================================================================
  # Enable sound with pipewire (modern audio system)
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================================
  # USER CONFIGURATION - User accounts and permissions
  # ============================================================================
  users.users.claw = { # Change username to match your preference
    isNormalUser = true;
    description = "ClaW";
    extraGroups = [ 
      "networkmanager"  # Network management
      "wheel"          # Sudo privileges
      "docker"         # Docker access (if using docker)
    ];
    
    # Set default shell
    shell = pkgs.zsh;
    
    # Initial password (change after first login!)
    initialPassword = "password123";
  };

  # ============================================================================
  # SYSTEM PACKAGES - Software installed system-wide
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    curl
    git
    vim
    neovim
    stow          # GNU Stow for dotfiles management
    
    # Development tools (matching your macOS setup)
    rustup
    python3
    
    # Terminal utilities
    fzf
    bat
    starship
    tree
    htop
    
    # GUI applications
    firefox
    brave
    vscode
    
    # System utilities
    btop          # Better htop
    ripgrep       # Better grep
    fd            # Better find
    zoxide        # Better cd
    
    # ZSH and related tools (matching your .zshrc setup)
    zsh
    zinit
    
    # Fonts (matching your nerd fonts from macOS)
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];

  # ============================================================================
  # PROGRAM CONFIGURATION - Enable and configure specific programs
  # ============================================================================
  programs = {
    # Enable zsh system-wide
    zsh.enable = true;
    
    # Enable git with some basic config
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
    
    # Enable Firefox with some privacy settings
    firefox = {
      enable = true;
      preferences = {
        "browser.startup.homepage" = "about:home";
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };

  # ============================================================================
  # SERVICES - Background services and daemons
  # ============================================================================
  services = {
    # Enable SSH for remote access
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false; # Use keys only
        PermitRootLogin = "no";
      };
    };
    
    # Docker service (optional)
    docker = {
      enable = true;
      # enableOnBoot = true;
    };
  };

  # Automatic garbage collection to save disk space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ============================================================================
  # NIX CONFIGURATION - Nix package manager settings
  # ============================================================================
  nix = {
    # Enable flakes and new nix command
    settings.experimental-features = [ "nix-command" "flakes" ];
    
    # Allow unfree packages (like Discord, Slack, etc.)
    nixpkgs.config.allowUnfree = true;
    
    # Automatic store optimization
    settings.auto-optimise-store = true;
  };

  # ============================================================================
  # SYSTEM CONFIGURATION - Version and state
  # ============================================================================
  # NixOS release version
  system.stateVersion = "24.05"; # Don't change this after installation
}
