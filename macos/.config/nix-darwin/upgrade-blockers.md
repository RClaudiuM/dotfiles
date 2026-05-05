# nix-darwin Upgrade Blockers

Last updated: 2026-05-05

---

## Current state

| Input | Pinned to | Why |
|---|---|---|
| `nix-homebrew` | `zhaofengli-wip` @ `37126f06` (Jun 2025) | latest breaks — see below |
| `brew-src` | Homebrew `5.0.16` (via `homebrew-brew` override) | workaround for cask bug |
| `nixpkgs` | `nixpkgs-unstable` @ `69dfebb` (Jun 2025) | latest breaks — see below |
| `nix-darwin` | `1dd19f1` (Jun 2025) | tied to nixpkgs |

---

## Blocker 1 — nix-homebrew latest requires `ruby_4_0`

**nix-homebrew** `aeb2069` (Apr 2026) changed its module to use `pkgs.ruby_4_0`:

```nix
# modules/default.nix:38
ruby = pkgs.ruby_4_0;
```

nixpkgs-unstable at Jun 2025 only has `ruby_3_1`, `ruby_3_2`, `ruby_3_3_4`.

**Attempted fix:** `nix flake update nixpkgs nix-homebrew` — nixpkgs May 2026 has `ruby_4_0`, so this resolves Blocker 1. But it surfaces Blocker 2.

**Workaround in place:** `inputs.brew-src.follows = "homebrew-brew"` with `homebrew-brew` pinned to `github:Homebrew/brew/5.0.16`. This keeps nix-homebrew at the old commit that uses `ruby_3_4`.

---

## Blocker 2 — nixpkgs May 2026 breaks `system-applications` builder

After updating nixpkgs to `73c703c` (May 2026), `darwin-rebuild build` fails:

```
pkgs.buildEnv error: Can't use string ("/Applications") as an ARRAY ref
while "strict refs" in use at .../builder.pl line 34.
```

Derivation: `system-applications.drv`

Likely cause: breaking change in how nix-darwin or `mkalias` handles the `/Applications` path — probably expects a list now where a string was passed.

**Not yet investigated.** Check nix-darwin changelog / release notes for the `system.activationScripts.applications` module between Jun 2025 and May 2026.

---

## To unblock the full upgrade

1. Fix `system-applications` builder error (Blocker 2) — likely a config change in `activation-scripts.nix` or `flake.nix`
2. Once that's resolved, run:
   ```bash
   nix flake update nixpkgs nix-homebrew
   ```
3. Remove the `homebrew-brew` override from `flake.nix` — no longer needed once nix-homebrew is on `aeb2069`+
4. Run `darwin-rebuild switch`

---

## Related files

- `github-issue-nix-homebrew-brew-src-outdated.md` — root cause of the original `4.5.6` cask crash
- `github-issue-homebrew-cask-depends-on-macos.md` — the upstream Homebrew API change that triggered it
