# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key Commands

**Full setup (auto-detects platform):**
```bash
./setup.sh
./setup.sh --dry-run   # preview changes without applying
```

**Apply nix-darwin changes (macOS):**
```bash
sudo darwin-rebuild switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS --verbose
```

**First-time nix-darwin bootstrap (before `darwin-rebuild` is available):**
```bash
nix run nix-darwin --experimental-features "nix-command flakes" -- switch --flake ~/dotfiles/macos/.config/nix-darwin#clawMacOS
```

**Re-stow after adding/moving files:**
```bash
stow -t ~ shared macos   # macOS
stow -t ~ shared devcontainer   # dev container
```

## Architecture

Dotfiles are managed with **GNU Stow**: each platform directory (`shared/`, `macos/`, `devcontainer/`) mirrors the `$HOME` structure. Running `stow -t ~ <dir>` creates symlinks at the corresponding paths in `$HOME`.

### Platform layers

| Layer | Directory | Purpose |
|---|---|---|
| Shared | `shared/` | Cross-platform shell scripts and fzf config, symlinked on all platforms |
| macOS | `macos/` | `.zshrc`, `.p10k.zsh`, `.gitconfig`, nix-darwin config, Karabiner, starship |
| Dev Container | `devcontainer/` | Lightweight zsh config, no Nix |
| Arch / NixOS | `arch/`, `archNixOS/` | Stubs, not yet complete |

### macOS nix-darwin (`macos/.config/nix-darwin/`)

The system is declared in `flake.nix` under configuration name `clawMacOS`. The flake imports three modules:

- **`modules/homebrew.nix`** — All Homebrew taps, brews, and casks. `onActivation.cleanup = "zap"` means packages removed from this file are uninstalled on next rebuild.
- **`modules/activation-scripts.nix`** — Post-activation hooks: removes Homebrew-managed Node.js, installs Node LTS via nvm, enables pnpm via corepack, sets up app aliases under `/Applications/Nix Apps/`.
- **`modules/system-defaults.nix`** — macOS system preferences set declaratively.

Nix-managed system packages (vim, rustup, awscli2, etc.) live in `flake.nix` under `environment.systemPackages`. Homebrew handles GUI apps and packages with macOS-specific needs (mongodb, postgresql, nvm).

### Shell stack (macOS)

`macos/.zshrc` uses **Zinit** as the plugin manager, loading Powerlevel10k, zsh-syntax-highlighting, zsh-autosuggestions, fzf-tab, and OMZ git/yarn/sudo/aws snippets. Node is managed via **nvm** (Homebrew-installed); Python via **pyenv**.

### Shared scripts (`shared/.config/scripts/`)

Auto-sourced by `.zshrc` and `.bashrc` at shell startup. Four utility scripts: `git-functions.sh`, `file-utils.sh`, `system-utils.sh`, `column-fallback.sh`.

## Important Constraints

- **Username in flake**: `flake.nix` hardcodes `primaryUser = "claudiu.roman"` and `user = "claudiu.roman"`. Update both when setting up on a different machine.
- **Homebrew `cleanup = "zap"`**: Removing a package from `homebrew.nix` will uninstall it on next `darwin-rebuild`. Add a comment if temporarily disabling instead of deleting.
- **Node.js is nvm-only**: The activation script in `activation-scripts.nix` actively removes Homebrew's Node.js to avoid conflicts. Never add `node` back to `homebrew.nix`.
- **`darwin-rebuild` requires sudo** on recent nix-darwin versions.
