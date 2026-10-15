#!/bin/bash
# TD-MapForge AI-engine dependency installer (macOS).
# Installs torch + transformers into TD-MapForge-python/ NEXT TO THE TOX,
# using TouchDesigner's bundled Python under x86_64 (TD 2025 runs translated
# on Apple Silicon; wheels must match x86_64).
set -euo pipefail

TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TD_PY="/Applications/TouchDesigner.app/Contents/Frameworks/Python.framework/Versions/3.11/bin/python3.11"

if [ ! -x "$TD_PY" ]; then
    echo "ERROR: TouchDesigner bundled Python not found at:"
    echo "  $TD_PY"
    echo "Edit TD_PY in this script to your TD install path."
    exit 1
fi

echo "Installing AI deps into: $TARGET_DIR/TD-MapForge-python"
arch -x86_64 "$TD_PY" -m pip install --target "$TARGET_DIR/TD-MapForge-python" \
    torch==2.2.2 torchvision==0.17.2 transformers==4.46.3

echo "Done. In TouchDesigner, open the TD-MapForge Engine page and click Load Model."
