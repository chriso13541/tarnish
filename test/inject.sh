#!/bin/bash
DYLIB="$(dirname $0)/tarnish.dylib"
APP=${1:-/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal}

echo "[Tarnish] Injecting into: $APP"
DYLD_INSERT_LIBRARIES="$DYLIB" \
DYLD_FORCE_FLAT_NAMESPACE=1 \
"$APP"
