# Default `brew-src` pinned to Homebrew 4.5.6 breaks casks with bare `depends_on :macos`

## Summary

The default `brew-src` input is pinned to Homebrew tag `4.5.6`. This version contains a bug in
`Library/Homebrew/cask/cask_loader.rb` that crashes when loading any cask that uses the bare
`depends_on :macos` stanza (meaning "requires macOS, any version"). Hundreds of popular casks
are affected: `mos`, `karabiner-elements`, `visual-studio-code`, `figma`, `discord`, and many
others.

The bug was fixed in Homebrew 5.0.x. Pinning `brew-src` to `5.0.16` (or any `5.0.x` release)
resolves the issue while staying on Ruby 3.4 (Homebrew 5.1.x requires Ruby 4.0).

---

## Error

Every affected cask fails with:

```
Error: Cask '<token>' definition is invalid: invalid 'depends_on macos' value: unknown or unsupported macOS version: ":"
```

This surfaces during `brew bundle` triggered by `darwin-rebuild switch`.

---

## Root cause

The Homebrew API serves these casks with the following JSON:

```json
"depends_on": { "macos": { ">=": [""] } }
```

The empty string `""` is the serialized form of the bare `depends_on :macos` stanza (no specific
version required). Homebrew 4.5.6's `cask_loader.rb` handles this incorrectly:

```ruby
# cask_loader.rb (4.5.6) — BUGGY
version_symbol = MacOSVersion::SYMBOLS.key(version_symbol) || version_symbol
#                SYMBOLS has no entry for "" → nil → || fallback keeps ""
[dep_key, "#{dep_type} :#{version_symbol}"]
#         string interpolation produces ">= :"  ← passed to DSL parser → crash
```

Homebrew 5.0.x fixed this in `api/cask.rb`:

```ruby
# api/cask.rb (5.0.x) — FIXED
version_symbol = MacOSVersion::SYMBOLS.key(version_symbol)
#                nil when not found — no || fallback
version_dep = "#{dep_type} :#{version_symbol}" if version_symbol
#             skipped when nil → no constraint applied → cask loads fine
```

---

## Why standard Homebrew users don't see this

Standard Homebrew is a live git repo. `brew update` pulls the latest Ruby code including the fix.
nix-homebrew installs Homebrew as a frozen Nix store path — `brew update` has no effect on the
Ruby code. Users are permanently stuck on the version of `cask_loader.rb` in the pinned `brew-src`.

---

## Affected `brew config` output (nix-homebrew)

```
ORIGIN: (none)
HEAD: (none)
Last commit: never
Branch: (none)
HOMEBREW_REPOSITORY: /opt/homebrew/Library/.homebrew-is-managed-by-nix
Homebrew Ruby: 3.4.4 => /nix/store/.../ruby-3.4.4/bin/ruby
```

---

## Requested fix

Update the default `brew-src` input from `4.5.6` to `5.0.16` (latest `5.0.x`).

`5.0.x` was chosen over `5.1.x` because `5.1.x` requires Ruby 4.0, which is not yet in nixpkgs.
`5.0.x` still requires Ruby 3.4, which nix-homebrew already provides.

```nix
# nix-homebrew flake.nix — suggested change
brew-src = {
  url = "github:Homebrew/brew/5.0.16";
  flake = false;
};
```

---

## Workaround (until fixed)

Users can override `brew-src` in their own flake:

```nix
inputs = {
  nix-homebrew = {
    url = "github:zhaofengli-wip/nix-homebrew";
    inputs.brew-src.follows = "homebrew-brew";
  };
  homebrew-brew = {
    url = "github:Homebrew/brew/5.0.16";
    flake = false;
  };
};
```

---

## Environment

- nix-homebrew: `37126f06` (2025-06-14)
- Homebrew (pinned): `4.5.6` / `7b4ef99`
- macOS: 15.3.1 arm64
- Nix: nixpkgs-unstable
