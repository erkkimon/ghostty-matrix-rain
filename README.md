# ghostty-matrix-rain

Matrix rain for [Ghostty](https://ghostty.org) that never moves a character.

Instead of drawing falling glyphs, the shader modulates the **brightness of
whatever is already on your screen**: each column of the terminal grid gets a
slow falling wave — bright head, fading trail — riding over your real text in
your real colors. Software running in the terminal can't tell it's happening;
there is nothing to break.

The default tuning is deliberately **subliminal**: while you work, text just
seems to breathe faintly. From across the room, your screen is unmistakably
raining.

## Install

```sh
mkdir -p ~/.config/ghostty
curl -o ~/.config/ghostty/matrix-rain.glsl \
  https://raw.githubusercontent.com/benquemax/ghostty-matrix-rain/main/matrix-rain.glsl
```

Add to `~/.config/ghostty/config`:

```ini
custom-shader = ~/.config/ghostty/matrix-rain.glsl
# optional, the classic look:
background = 000000
foreground = 00ff41
```

Open a new Ghostty window. (Shader changes always apply to new windows, not
existing ones.)

## Calibrate (recommended)

The wave steps align to your terminal's character grid. Font cell size varies
by font, size, and display scale, so measure yours — run this **inside a
Ghostty window**:

```sh
curl -o /tmp/rain-calibrate.sh \
  https://raw.githubusercontent.com/benquemax/ghostty-matrix-rain/main/rain-calibrate.sh
bash /tmp/rain-calibrate.sh
```

It reads the real cell size from the terminal (`TIOCGWINSZ`) and patches
`CELL_W`/`CELL_H` in the installed shader. Re-run after changing font or
font size.

## Tuning

All knobs are constants at the top of `matrix-rain.glsl`:

| Constant | Default | Meaning |
|---|---|---|
| `CELL_W`, `CELL_H` | 10, 20 | cell size in px — use the calibrate script |
| `MIN_B` | 0.85 | brightness floor; lower = deeper, more visible dimming |
| `TAIL` | 4.0 | trail falloff; bigger = shorter streaks |
| `SPEED` | 0.12 | fall speed in screens/second; slow speeds evade peripheral vision |
| `GLOW` | 0.008 | faint green wash on empty cells so sparse text doesn't read as blinking; 0 disables |
| `GLOW_COLOR` | Matrix green | glow tint |

Two starting points:

- **Subliminal** (default): `MIN_B 0.85, SPEED 0.12, GLOW 0.008` — invisible
  up close, visible from afar.
- **Cinematic**: `MIN_B 0.30, SPEED 0.22, GLOW 0.02` — you're in the Matrix
  and you know it.

## Notes

- The shader post-processes the whole frame, so inline images (Kitty graphics
  protocol) get rained on too. Feature, obviously.
- Designed for dark backgrounds: dimming pixels only reads as "font opacity"
  when the background is near-black.
- `custom-shader-animation = always` in the Ghostty config keeps it raining
  while unfocused, at some battery cost.

## License

MIT
