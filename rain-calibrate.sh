#!/bin/bash
# Run this INSIDE a Ghostty window. Reads the terminal's real cell size in
# pixels (TIOCGWINSZ) and patches CELL_W/CELL_H in matrix-rain.glsl to match.
read -r rows cols xpx ypx < <(python3 -c "
import fcntl, struct, termios
print(*struct.unpack('HHHH', fcntl.ioctl(open('/dev/tty'), termios.TIOCGWINSZ, b'\0'*8)))")
if [ -z "$xpx" ] || [ "$xpx" -eq 0 ]; then
  echo "terminal did not report pixel size — are you inside Ghostty?" >&2
  exit 1
fi
w=$((xpx / cols)); h=$((ypx / rows))
sed -i -E \
  -e "s/^const float CELL_W = [0-9.]+/const float CELL_W = $w.0/" \
  -e "s/^const float CELL_H = [0-9.]+/const float CELL_H = $h.0/" \
  ~/.config/ghostty/matrix-rain.glsl
echo "cell = ${w}x${h} px — shader patched, open a new Ghostty window"
