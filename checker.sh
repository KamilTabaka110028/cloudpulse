#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-localhost}"

echo "=== Rozpoczynam sprawdzanie celu: $TARGET ==="

# Sprawdzamy czy cel odpowiada na ping (1 pakiet)
if ping -c 1 "$TARGET" > /dev/null 2>&1; then
    echo "✅ [SUKCES] Cel $TARGET działa i odpowiada!"
    exit 0
else
    echo "❌ [BŁĄD] Cel $TARGET nie odpowiada na ping!" >&2
    exit 1
fi
