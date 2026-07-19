#!/usr/bin/env bash
#
# build.sh - Creates the js-dos ZIP bundle (pong.zip) from PONG.EXE
# Usage: ./web/build.sh              (expects PONG.EXE in project root)
#        ./web/build.sh /path/to/PONG.EXE
#
# Requires: python3 (available on all major OS / CI runners)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

EXE="${1:-$PROJECT_ROOT/PONG.EXE}"
OUT_ZIP="$SCRIPT_DIR/pong.zip"

if [ ! -f "$EXE" ]; then
    echo "Error: PONG.EXE not found at $EXE" >&2
    echo "Build the game first (MASM: ml /AT /Zd pong.asm && link /TINY pong.obj)" >&2
    exit 1
fi

rm -f "$OUT_ZIP"

python3 - "$EXE" "$OUT_ZIP" <<'PYEOF'
import zipfile, sys, os

src, dst = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zf:
    zf.write(src, os.path.basename(src))

size = os.path.getsize(dst)
print(f"Build complete: {dst} ({size} bytes)")
PYEOF
