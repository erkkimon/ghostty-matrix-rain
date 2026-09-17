// Matrix rain for Ghostty — full-green variant.
// Every glyph is tinted to matrix green (luminance preserved), and each grid
// cell's brightness rides a wave falling down its column. No characters move.
// Tune CELL_W / CELL_H to your font's cell size in pixels for crisp per-cell steps.

const float CELL_W = 10.0; // cell width in px (depends on font/size)
const float CELL_H = 20.0; // cell height in px
const float MIN_B  = 0.85;  // brightness floor — text stays readable
const float TAIL   = 4.0;   // bigger = shorter trail
const float SPEED  = 0.12;  // base fall speed, screens per second
const float GLOW   = 0.018; // rain glow on empty cells (green trail wash)
const float TINT   = 1.0;   // 1.0 = force every glyph fully green, 0.0 = keep original colors
const float GRAIN  = 4.0;   // rain cells per text cell — raise for finer rain
const float FOCUS  = 0.70;  // rain brightness on the focused window (1.0 = full)
const float UNFOC  = 0.35;  // rain brightness on an unfocused window
const vec3  MATRIX = vec3(0.0, 1.0, 0.25); // matrix green

float hash(float n) { return fract(sin(n * 12.9898) * 43758.5453); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 src = texture(iChannel0, fragCoord / iResolution.xy);

    // integer cell coordinates, row 0 at the top of the screen.
    // GRAIN subdivides the text cell so the rain can be finer than the font.
    // It lives apart from CELL_W/CELL_H because rain-calibrate.sh rewrites those
    // two on every run — folding granularity into them would be lost each time.
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

    // recolor glyphs to matrix green, keeping each pixel's brightness (luminance)
    float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));
    // MATRIX's own luminance is only ~0.62, so a naive luminance-preserving tint
    // dims already-green text by ~38%. Normalise the tint to unit luminance so
    // full-brightness green stays full-brightness.
    vec3  tint   = MATRIX / dot(MATRIX, vec3(0.299, 0.587, 0.114));
    vec3  tinted = mix(src.rgb, tint * lum, TINT);

    // Ghostty passes the surface's focus state in as `iFocus` (0 when unfocused).
    // It scales the rain only, never the glyphs, so background windows stay
    // readable. Requires `custom-shader-animation = always`, otherwise unfocused
    // surfaces stop redrawing and freeze on their last focused frame.
    float focusDim = (iFocus > 0) ? FOCUS : UNFOC;

    // rain trail wash on dark pixels only, so glyphs keep their green
    float darkness = 1.0 - max(tinted.r, max(tinted.g, tinted.b));
    vec3  glow = MATRIX * trail * GLOW * darkness * focusDim;

    fragColor = vec4(tinted * b + glow, src.a);
}
