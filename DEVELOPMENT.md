# 🛠 Development Guide

Everything you need to work on the Sham theme — from editing a color to
publishing a new release to the Marketplace.

---

## 1. Setup

Install dependencies (Bun):

```bash
bun install
```

| Script | What it does |
| ------ | ------------ |
| `bun run watch` | Regenerates `themes/*.json` on every save and keeps `package.json` `contributes` in sync |
| `bun run check` | TypeScript check (`tsc --noEmit`) |
| `bun run update-color-keys` | Refreshes the generated VS Code color-key list |
| `bun run vsce` | Generates themes + packages `sham-<version>.vsix` |

---

## 2. The everyday loop

1. Open **two terminals**.
2. Terminal 1 — keep the watcher running:

   ```bash
   bun run watch
   ```

3. Edit a palette in [`src/palettes.ts`](src/palettes.ts) or add/remove a theme
   in [`src/index.ts`](src/index.ts). The watcher regenerates the theme JSONs
   and the `contributes.themes` section of `package.json` automatically.
4. Preview it: **Run and Debug** panel → `F5`. A new VS Code window opens with
   the theme loaded; switch themes with `Ctrl+K Ctrl+T` / `⌘+K ⌘+T`.
5. Check types before you commit:

   ```bash
   bun run check
   ```

---

## 3. From "I made a change" to published release

The complete, command-by-command walkthrough.

```bash
# ─── 1. make your change ─────────────────────────────────────────────
# e.g. edit src/palettes.ts — the watcher (bun run watch) already
# regenerated themes/*.json and package.json for you

# ─── 2. stop the watcher ─────────────────────────────────────────────
# press Ctrl+C in the watcher terminal once you're done

# ─── 3. verify nothing is broken ─────────────────────────────────────
bun run check

# ─── 4. build the theme and do a smoke-test install ──────────────────
bun run vsce
code --install-extension sham-1.0.0.vsix   # uses the version in package.json

# ─── 5. commit the change ────────────────────────────────────────────
# messages must be conventional commits (commitlint + husky are wired up)
# allowed examples: feat:, fix:, docs:, chore:, ci:, refactor:, style:
git add -A
git commit -m "feat: add warm accent to shift palette"

# ─── 6. bump the version ─────────────────────────────────────────────
npm version patch     # 1.0.0 → 1.0.1 (bug fixes / color tweaks)
# or
npm version minor     # 1.0.0 → 1.1.0 (new themes / new features)
# this commits "1.0.1" AND creates the git tag v1.0.1 automatically

# also update the version badge in README.md if you want it accurate :)
# (do it before step 5 so it lands in the same commit)

# ─── 7. push everything (commits + the version tag) ──────────────────
git push origin master --follow-tags

# ─── 8. let GitHub Actions build the release ─────────────────────────
# the v1.0.1 tag triggers .github/workflows/release.yml, which:
#   • installs deps, generates themes, packages the .vsix
#   • checks the tag matches package.json (fails loudly otherwise)
#   • creates a GitHub release with sham-1.0.1.vsix attached
# monitor: https://github.com/lorens-osman-dev/sham-vscode-theme/actions
```

### 8a. Publishing to the Marketplace

**Option A — automatic (recommended):** add a `VSCE_PAT` repository secret
(Settings → Secrets and variables → Actions → New repository secret) with a
Personal Access Token that has **Marketplace → Manage** scope. The release
workflow publishes the marketplace listing in the same run — step 8 is all
you ever do.

**Option B — manual**, from your machine:

```bash
npx vsce publish          # publishes the version from package.json
# or let vsce bump for you in one step:
npx vsce publish patch
```

If a second developer asks for your PAT login state:

```bash
npx vsce ls-publishers    # check which publisher you're logged in as
```

### 8b. Sanity checks after publishing

```bash
# the one-liner from the README should now find the new release:
curl -fsSL https://raw.githubusercontent.com/lorens-osman-dev/sham-vscode-theme/master/scripts/downloadAndInstall.sh | bash
```

The market listing can take a few minutes to refresh:
`https://marketplace.visualstudio.com/items?itemName=lorensosman.sham`

---

## 4. How the source is organized

```
src/
├── index.ts                  # theme registry — the source of truth
├── palettes.ts               # all color palettes
├── themeClass.ts             # assembles colors + tokens into a theme
├── themeParts/
│   ├── colorsSection/        # workbench colors (activity bar, tabs, terminal…)
│   └── tokenColorsSection/   # syntax/token colors per language family
├── templates/                # language sample files for visual testing
├── types/                    # generated key list + palette types
└── util/                     # JSON writing & manifest syncing
themes/                      # generated theme JSON — the shipped artifact
assets/                      # icon & preview images
scripts/                     # install helper + color-key generator
```

Rule of thumb: **never edit `themes/*.json` directly** — they are generated.
Edit palettes/theme parts, and let the watcher produce the JSON.

---

## 5. Troubleshooting

| Symptom | Cause & fix |
| ------- | ----------- |
| `vsce package` → `Invalid URL` | An `@` inside an HTML `<img src>` in README/CHANGELOG. Use markdown `![](...)` or rename the asset without `@`. |
| Watcher rewrites `package.json` oddly | It only touches `contributes.themes` — other edits are safe. |
| Theme JSONs out of sync after pulling changes | Run `bun run src/index.ts` once (or start `bun run watch`). |
| TypeScript rejects a color key you're sure is real | Run `bun run update-color-keys` to refresh the generated key list. |
| `vsce` complains about the PAT | Re-run `npx vsce login lorensosman`. |
| Tag vs version mismatch in CI | Delete+recreate: `git tag -f v<version> && git push --force origin v<version>` |
