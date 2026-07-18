#!/bin/bash
# Installs the matrix-rain shader for Ghostty. Idempotent — safe to re-run.
set -e
base=https://raw.githubusercontent.com/erkkimon/ghostty-matrix-rain/main
dir=~/.config/ghostty
mkdir -p "$dir"
curl -fsSL "$base/matrix-rain.glsl"    -o "$dir/matrix-rain.glsl"
curl -fsSL "$base/rain-calibrate.sh"   -o "$dir/rain-calibrate.sh"
chmod +x "$dir/rain-calibrate.sh"
grep -qs "matrix-rain.glsl" "$dir/config" || \
  printf '\ncustom-shader = ~/.config/ghostty/matrix-rain.glsl\n' >> "$dir/config"
echo "Installed. Open a NEW Ghostty window, then run:"
echo "  ~/.config/ghostty/rain-calibrate.sh"
echo "inside it to align the rain to your font's grid (then open another window)."
