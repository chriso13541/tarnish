#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DYLIB="$SCRIPT_DIR/../tarnish.dylib"
APP=${1:-/System/Applications/TextEdit.app/Contents/MacOS/TextEdit}

echo "[Tarnish] Injecting into: $APP"
echo "[Tarnish] Using dylib: $DYLIB"

if [ ! -f "$DYLIB" ]; then
    echo "[Tarnish] ERROR: dylib not found at $DYLIB"
    exit 1
fi

DYLD_INSERT_LIBRARIES="$DYLIB" \
DYLD_FORCE_FLAT_NAMESPACE=1 \
"$APP"