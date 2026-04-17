#!/bin/bash
DYLIB="$(dirname $0)/../tarnish.dylib"
APP=${1:-/System/Applications/TextEdit.app/Contents/MacOS/TextEdit}

echo "[Tarnish] Injecting into: $(basename $APP)"
DYLD_INSERT_LIBRARIES="$DYLIB" \
DYLD_FORCE_FLAT_NAMESPACE=1 \
"$APP"