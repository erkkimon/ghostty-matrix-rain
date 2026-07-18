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

## Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/erkkimon/ghostty-matrix-rain/main/install.sh | bash
```

Then:

1. Open a **new** Ghostty window — it's raining. (Shader changes always apply
   to new windows, not existing ones.)
2. Inside that window, align the rain to your font's grid:

   ```sh
   ~/.config/ghostty/rain-calibrate.sh
   ```

   and open one more new window. Re-run after changing font or font size.

For the classic look, also add to `~/.config/ghostty/config`:

```ini
background = 000000
foreground = 00ff41
```

## Manual install

Copy `matrix-rain.glsl` to `~/.config/ghostty/` and add to
`~/.config/ghostty/config`:

```ini
custom-shader = ~/.config/ghostty/matrix-rain.glsl
```

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
