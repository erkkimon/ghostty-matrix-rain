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
# Without this, only the FOCUSED surface animates, so unfocused windows freeze
# on their last focused frame and never show the dimmed (UNFOC) look.
grep -qs "custom-shader-animation" "$dir/config" || \
  printf 'custom-shader-animation = always\n' >> "$dir/config"
echo "Installed. Open a NEW Ghostty window, then run:"
echo "  ~/.config/ghostty/rain-calibrate.sh"
echo "inside it to align the rain to your font's grid (then open another window)."
