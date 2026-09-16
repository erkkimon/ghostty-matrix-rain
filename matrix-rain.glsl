// Matrix rain for Ghostty — no characters move; each grid cell's brightness
// rides a wave falling down its column.
// Tune CELL_W / CELL_H to your font's cell size in pixels for crisp per-cell steps.

const float CELL_W = 10.0; // cell width in px (depends on font/size)
const float CELL_H = 20.0; // cell height in px
const float MIN_B  = 0.85; // brightness floor — text stays readable
const float TAIL   = 4.0;  // bigger = shorter trail
const float SPEED  = 0.12; // base fall speed, screens per second
const float GLOW   = 0.025; // background glow strength, 0 = text-only rain (subliminal: 0.008-0.05)
const float GRAIN  = 2.0;  // rain cells per text cell — raise for finer rain
const float TINT   = 1.0;  // 1.0 = force every glyph green, 0.0 = keep terminal colors
const float UNFOC  = 0.55; // brightness of an unfocused surface (1.0 = no dimming)
const vec3  MATRIX = vec3(0.0, 1.0, 0.25); // Matrix green

float hash(float n) { return fract(sin(n * 12.9898) * 43758.5453); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 src = texture(iChannel0, fragCoord / iResolution.xy);

    // integer cell coordinates, row 0 at the top of the screen.
    // GRAIN subdivides the text cell so the rain can be finer than the font.
    // It is kept apart from CELL_W/CELL_H because rain-calibrate.sh rewrites
    // those two on every run — granularity folded in would be lost each time.
    float cw   = CELL_W / GRAIN;
    float ch   = CELL_H / GRAIN;
    float col  = floor(fragCoord.x / cw);
    float row  = floor((iResolution.y - fragCoord.y) / ch);
    float rows = iResolution.y / ch;

    // this column's falling head: position in [0,1), 0 = top
    float speed = SPEED * (0.6 + 0.8 * hash(col));
    float head  = fract(iTime * speed + hash(col * 7.31));

    // how far the head has fallen past this cell (wraps around)
    float d = head - (row / rows);
    if (d < 0.0) d += 1.0;

    // bright at the head, exponential fade up the trail, floor below
    float trail = exp(-d * TAIL);
    float b = MIN_B + (1.0 - MIN_B) * trail;

    // recolor glyphs to Matrix green, keeping each pixel's brightness (luminance).
    // MATRIX's own luminance is only ~0.62, so tinting with it directly would dim
    // already-green text by ~38%; normalise to unit luminance so full stays full.
    float lum    = dot(src.rgb, vec3(0.299, 0.587, 0.114));
    vec3  tint   = MATRIX / dot(MATRIX, vec3(0.299, 0.587, 0.114));
    vec3  tinted = mix(src.rgb, tint * lum, TINT);

    // glow fills only dark pixels — glyphs keep their own color
    float darkness = 1.0 - max(tinted.r, max(tinted.g, tinted.b));
    vec3 glow = MATRIX * trail * GLOW * darkness;

    // Ghostty passes the surface's focus state in as `iFocus` (0 when unfocused),
    // so dimming inactive windows needs no window-manager support. Requires
    // `custom-shader-animation = always`, otherwise unfocused surfaces stop
    // redrawing and freeze on their last focused (undimmed) frame.
    float focusDim = (iFocus > 0) ? 1.0 : UNFOC;

    fragColor = vec4((tinted * b + glow) * focusDim, src.a);
}
