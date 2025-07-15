extern number flashAmount;   // 0.0 to 1.0
extern vec4 flashColor;      // flash color (red, white, etc.)

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 baseColor = Texel(texture, texture_coords) * color;
    return mix(baseColor, flashColor, flashAmount);
}