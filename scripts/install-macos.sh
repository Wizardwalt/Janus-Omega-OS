#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
#   JanusOS — macOS Installer
#   Usage: curl -fsSL https://raw.githubusercontent.com/Wizardwalt/Janus-Omega-OS/main/scripts/install-macos.sh | bash
# ══════════════════════════════════════════════════════════════════
set -euo pipefail

REPO="Wizardwalt/Janus-Omega-OS"
INSTALL_DIR="$HOME/.janus"
BIN_LINK="/usr/local/bin/janus-web"

# ── Detect architecture ───────────────────────────────────────────
ARCH=$(uname -m)
case "$ARCH" in
    arm64)  BUNDLE_ARCH="arm64" ;;
    x86_64) BUNDLE_ARCH="x86_64" ;;
    *)      echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo ""
echo "  ██╗ █████╗ ███╗   ██╗██╗   ██╗███████╗"
echo "  ██║██╔══██╗████╗  ██║██║   ██║██╔════╝"
echo "  ██║███████║██╔██╗ ██║██║   ██║███████╗"
echo "  ██║██╔══██║██║╚██╗██║██║   ██║╚════██║"
echo "  ██║██║  ██║██║ ╚████║╚██████╔╝███████║"
echo "  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝"
echo ""
echo "  JanusOS macOS Installer  |  arch: $ARCH"
echo ""

# ── Find the latest release ───────────────────────────────────────
echo "→ Fetching latest release..."
LATEST=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | \
    python3 -c "import sys,json; r=json.load(sys.stdin); \
    assets=[a['browser_download_url'] for a in r['assets'] if '${BUNDLE_ARCH}' in a['name'] and a['name'].endswith('.tar.gz')]; \
    print(assets[0] if assets else '')" 2>/dev/null || true)

if [ -z "$LATEST" ]; then
    echo ""
    echo "  No pre-built release found for $BUNDLE_ARCH."
    echo "  Build from source instead:"
    echo ""
    echo "    git clone https://github.com/${REPO}"
    echo "    cd Janus-Omega-OS"
    echo "    cargo run --bin janus-web"
    echo "    # Open http://localhost:5000"
    echo ""
    exit 0
fi

# ── Download & install ────────────────────────────────────────────
echo "→ Downloading $LATEST..."
TMPDIR=$(mktemp -d)
curl -fsSL "$LATEST" -o "$TMPDIR/janus.tar.gz"

echo "→ Installing to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMPDIR/janus.tar.gz" -C "$TMPDIR"
EXTRACTED=$(ls "$TMPDIR" | grep -v janus.tar.gz | head -1)
cp -r "$TMPDIR/$EXTRACTED/"* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/janus-web"
chmod +x "$INSTALL_DIR/launch.sh"
rm -rf "$TMPDIR"

# ── Symlink binary ────────────────────────────────────────────────
if [ -d "$(dirname $BIN_LINK)" ] && [ -w "$(dirname $BIN_LINK)" ]; then
    ln -sf "$INSTALL_DIR/janus-web" "$BIN_LINK"
    echo "→ Linked: janus-web → $BIN_LINK"
fi

echo ""
echo "  ✓ JanusOS installed to $INSTALL_DIR"
echo ""
echo "  Start:"
echo "    $INSTALL_DIR/launch.sh"
echo "    # or: janus-web  (then open http://localhost:5000)"
echo ""
