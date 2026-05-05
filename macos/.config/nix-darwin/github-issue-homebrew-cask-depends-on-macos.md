## What were you trying to do (and why)?

Install or evaluate core casks using Homebrew’s default **install-from-API** path—for example `mos` and a few others—either directly (`brew install --cask`) or via **`brew bundle`**. This is normal use (CLI installs and declarative bundle files).

I manage macOS with a **Nix flake** (nix-darwin, including nix-homebrew), so Homebrew is integrated declaratively. Some **`brew doctor`** warnings in that setup are **expected** (e.g. nix-managed `HOMEBREW_REPOSITORY` without a normal `git` `origin`, optional untapped `homebrew/core` / `homebrew/cask` when using API-only installs). Those are unrelated to this report; the failure here is specifically cask evaluation from API JSON / `depends_on macos`.

Related context: several affected casks still use bare `depends_on :macos` in `homebrew-cask`; the [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) documents `depends_on macos:` with an explicit release or comparison string. Published API JSON for these casks currently shows `depends_on.macos` as `">=": [""]` (empty string), which may be a serialization bug.

---

## What happened (include all command output)?

`brew` fails while loading the cask from API-backed metadata—for example invalid `depends_on macos`, `MacOSVersion.from_symbol` / type errors, or “unknown or unsupported macOS version” involving `":"`.

Published JSON for `mos` includes a broken `depends_on` shape (reproducible without Homebrew):

```bash
curl -fsSL 'https://formulae.brew.sh/api/cask/mos.json' | python3 -c "import json,sys; d=json.load(sys.stdin); print('depends_on:', d.get('depends_on')); print('generated_date:', d.get('generated_date'))"
```

Example output (observed):

```
depends_on: {'macos': {'>=': ['']}}
generated_date: …
```

The same `{'macos': {'>=': ['']}}` pattern appears for other tokens such as `karabiner-elements`, `visual-studio-code`, `figma`, and `discord` when querying `https://formulae.brew.sh/api/cask/<token>.json`.

**Homebrew command output** (paste your complete terminal output below after running the reproduction steps):

```
(paste full output of: brew update
 paste full output of: HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask mos --dry-run
 optional: brew config
 optional: brew doctor)
```

---

## What did you expect to happen?

The cask should load from the API with a valid `depends_on` (or no macOS constraint when “any macOS” is intended), and `brew install --cask mos` / `--dry-run` should succeed on a supported macOS version. The same for other affected casks and for `brew bundle` entries that list them.

---

## Step-by-step reproduction instructions (by running `brew` commands)

1. Ensure Homebrew is up to date:

   ```bash
   brew update
   ```

2. Reproduce with a core cask using the default API path (no `HOMEBREW_NO_INSTALL_FROM_API`):

   ```bash
   HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask mos --dry-run
   ```

3. (Optional) Confirm the same class of failure on another affected cask:

   ```bash
   HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask discord --dry-run
   ```

4. (Optional) If maintainers want a second data point from `brew` itself:

   ```bash
   HOMEBREW_NO_AUTO_UPDATE=1 brew info --cask mos
   ```

If any step succeeds on your machine, note your `brew config` and the exact `depends_on` field from `curl` for `mos.json` that day so the report stays accurate.
