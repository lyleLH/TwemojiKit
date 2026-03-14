#!/bin/bash
#
# Updates the bundled twemoji.min.js and version constant to the latest release.
#
# Usage:
#   ./Scripts/update-twemoji.sh          # auto-detect latest version
#   ./Scripts/update-twemoji.sh 15.2.0   # specify a version
#

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JS_DEST="$REPO_ROOT/Sources/Core/twemoji.min.js"
VERSION_FILE="$REPO_ROOT/Sources/TwemojiImage.swift"

# Determine version
if [ -n "${1:-}" ]; then
    VERSION="$1"
else
    echo "Fetching latest twemoji release tag..."
    VERSION=$(curl -s "https://api.github.com/repos/jdecked/twemoji/releases/latest" \
        | grep '"tag_name"' \
        | sed -E 's/.*"v?([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        echo "Error: Could not determine latest version. Specify one manually:"
        echo "  $0 15.2.0"
        exit 1
    fi
fi

echo "Updating twemoji to version $VERSION ..."

# 1. Download twemoji.min.js
JS_URL="https://unpkg.com/@nicepkg/twemoji@${VERSION}/dist/twemoji.min.js"
echo "Downloading $JS_URL ..."
HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$JS_DEST.tmp" "$JS_URL")

if [ "$HTTP_CODE" != "200" ]; then
    # Fallback: try the jdecked GitHub raw URL
    JS_URL="https://cdn.jsdelivr.net/gh/jdecked/twemoji@v${VERSION}/dist/twemoji.min.js"
    echo "First URL failed ($HTTP_CODE), trying $JS_URL ..."
    HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$JS_DEST.tmp" "$JS_URL")
fi

if [ "$HTTP_CODE" != "200" ]; then
    rm -f "$JS_DEST.tmp"
    echo "Error: Failed to download twemoji.min.js (HTTP $HTTP_CODE)"
    exit 1
fi

mv "$JS_DEST.tmp" "$JS_DEST"
echo "Updated $JS_DEST"

# 2. Update version constant in TwemojiImage.swift
OLD_VERSION=$(grep 'private let TwemojiCoreVersion' "$VERSION_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
if [ "$OLD_VERSION" != "$VERSION" ]; then
    sed -i '' "s/private let TwemojiCoreVersion = \"$OLD_VERSION\"/private let TwemojiCoreVersion = \"$VERSION\"/" "$VERSION_FILE"
    echo "Updated TwemojiCoreVersion: $OLD_VERSION -> $VERSION"
else
    echo "TwemojiCoreVersion already at $VERSION"
fi

echo ""
echo "Done! Changes:"
echo "  - Sources/Core/twemoji.min.js  (updated JS library)"
echo "  - Sources/TwemojiImage.swift   (version constant)"
echo ""
echo "Next steps:"
echo "  1. Run 'swift build' to verify the build"
echo "  2. Run 'swift test' to verify parsing still works"
echo "  3. Commit the changes"
