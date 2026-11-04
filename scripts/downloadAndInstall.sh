#!/usr/bin/env bash
#
# Sham — VS Code theme
# Downloads the latest Sham theme release and installs it via the VS Code CLI.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/lorens-osman-dev/sham-vscode-theme/master/scripts/downloadAndInstall.sh | bash
#   bash downloadAndInstall.sh              # install latest release
#   bash downloadAndInstall.sh 1.2.3        # install a specific version
#   FORCE=1 bash downloadAndInstall.sh      # reinstall even if same version
#
set -euo pipefail

REPO="lorens-osman-dev/sham-vscode-theme"
EXT_ID="lorensosman.sham"
FALLBACK_VERSION="1.0.0"

# ---------------------------------------------------------------- appearance
BLUE='\033[1;34m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; DIM='\033[2m'; NC='\033[0m'
info()  { printf "${BLUE}▸${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}!${NC} %s\n" "$*"; }
fail()  { printf "${RED}✗ %s${NC}\n" "$*" >&2; exit 1; }

# ---------------------------------------------------------------- 1. fetch tool
if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -q "$1" -O "$2"; }
else
  fail "Neither 'curl' nor 'wget' found. Please install one and retry."
fi

# resolve a URL (exit code 1 silently on http >= 400, to allow fallbacks)

# ---------------------------------------------------------------- 2. VS Code?
CLI=""
for candidate in code code-insiders codium; do
  if command -v "$candidate" >/dev/null 2>&1; then CLI="$candidate"; break; fi
done
[ -n "$CLI" ] || fail "VS Code CLI ('code') not found in PATH.
  Install VS Code first: https://code.visualstudio.com/download
  (Tip: in VS Code press Ctrl+Shift+P and run 'Shell Command: Install code command in PATH')"
ok "Editor CLI found: $CLI"

# ---------------------------------------------------------------- 3. Which version?
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  info "Looking up the latest release on GitHub…"
  LATEST_PROBE=$(mktemp 2>/dev/null) || LATEST_PROBE=""
  if [ -n "$LATEST_PROBE" ] \
      && fetch "https://api.github.com/repos/${REPO}/releases/latest" "$LATEST_PROBE" 2>/dev/null \
      && grep -q '"tag_name"' "$LATEST_PROBE"; then
    TARGET=$(sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\(v\?\)\([^"]*\)".*/\2/p' "$LATEST_PROBE" | head -1)
  fi
  rm -f "$LATEST_PROBE"
  [ -n "$TARGET" ] || TARGET="$FALLBACK_VERSION"
fi
ok "Target version: $TARGET"

# ---------------------------------------------------------------- 4. Already installed?
INSTALLED=$("$CLI" --show-versions --list-extensions 2>/dev/null \
  | grep -i "^${EXT_ID}@" | head -1 | cut -d@ -f2 || true)
if [ -n "$INSTALLED" ]; then
  if [ "$INSTALLED" = "$TARGET" ] && [ "${FORCE:-0}" != "1" ]; then
    ok "Sham $INSTALLED is already installed — nothing to do. Use an argument or FORCE=1 to reinstall."
    exit 0
  fi
  warn "Installed version: $INSTALLED → updating to $TARGET"
else
  info "Sham is not installed yet."
fi

# ---------------------------------------------------------------- 5. Download
TMPDIR_DL=$(mktemp -d)
trap 'rm -rf "$TMPDIR_DL"' EXIT
VSIX="$TMPDIR_DL/sham-${TARGET}.vsix"

URL="https://github.com/${REPO}/releases/download/v${TARGET}/sham-${TARGET}.vsix"
info "Downloading $URL …"
if ! fetch "$URL" "$VSIX"; then
  fail "Could not download sham-${TARGET}.vsix.
  Check that the release exists: https://github.com/${REPO}/releases"
fi
ok "Downloaded $(wc -c < "$VSIX" | tr -d ' ') bytes"

# ---------------------------------------------------------------- 6. Install
info "Installing extension…"
if "$CLI" --install-extension "$VSIX" >/dev/null 2>&1; then
  ok "Sham ${TARGET} installed!"
  printf "\n  Open the command palette (Ctrl+K Ctrl+T / Cmd+K Cmd+T) and pick your favorite Sham theme.\n\n"
else
  fail "Installation failed. Try manually:
  ${CLI} --install-extension /path/to/sham-${TARGET}.vsix"
fi
