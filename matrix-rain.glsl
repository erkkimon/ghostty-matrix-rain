// Matrix rain for Ghostty — no characters move; each grid cell's brightness
// rides a wave falling down its column. Colors stay whatever the terminal drew.
// Tune CELL_W / CELL_H to your font's cell size in pixels for crisp per-cell steps.

const float CELL_W = 10.0; // cell width in px (depends on font/size)
const float CELL_H = 20.0; // cell height in px
const float MIN_B  = 0.85; // brightness floor — text stays readable
const float TAIL   = 4.0;  // bigger = shorter trail
const float SPEED  = 0.12; // base fall speed, screens per second
const float GLOW   = 0.008; // background glow strength, 0 = text-only rain (subliminal: 0.008-0.05)
const vec3  GLOW_COLOR = vec3(0.0, 1.0, 0.25); // Matrix green

float hash(float n) { return fract(sin(n * 12.9898) * 43758.5453); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 src = texture(iChannel0, fragCoord / iResolution.xy);

    // integer cell coordinates, row 0 at the top of the screen
    float col  = floor(fragCoord.x / CELL_W);
    float row  = floor((iResolution.y - fragCoord.y) / CELL_H);
    float rows = iResolution.y / CELL_H;

    // this column's falling head: position in [0,1), 0 = top
    float speed = SPEED * (0.6 + 0.8 * hash(col));
    float head  = fract(iTime * speed + hash(col * 7.31));

    // how far the head has fallen past this cell (wraps around)
    float d = head - (row / rows);
    if (d < 0.0) d += 1.0;

    // bright at the head, exponential fade up the trail, floor below
    float trail = exp(-d * TAIL);
    float b = MIN_B + (1.0 - MIN_B) * trail;

    // glow fills only dark pixels — glyphs keep their own color
    float darkness = 1.0 - max(src.r, max(src.g, src.b));
    vec3 glow = GLOW_COLOR * trail * GLOW * darkness;

    fragColor = vec4(src.rgb * b + glow, src.a);
}
