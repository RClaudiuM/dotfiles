{ config, pkgs, ... }:

{
  system.activationScripts = {
    removeHomebrewNode = {
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
    };

    nvmInstallNodeAndPnpm = {
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

    fixHomebrewSwift = {
      text = ''
        echo "==============================================="
        echo "Configuring Homebrew to use system Swift..."
        if [ -d "/Library/Developer/CommandLineTools" ]; then
          echo "System Command Line Tools found"
        else
          echo "Warning: Command Line Tools not found. Install with: xcode-select --install"
        fi
        echo "==============================================="
      '';
    };

    postActivation.text = ''
      ${config.system.activationScripts.removeHomebrewNode.text}
      ${config.system.activationScripts.nvmInstallNodeAndPnpm.text}
      ${config.system.activationScripts.fixHomebrewSwift.text}
    '';

    applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      pkgs.lib.mkForce ''
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
  };
}