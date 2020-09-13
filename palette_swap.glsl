extern vec4 palette[4];

vec4 effect(vec4 draw_color, Image texture, vec2 texture_coordinates, vec2 screen_coordinates)
{
    vec4 texture_color = Texel(texture, texture_coordinates);
    vec4 actual_color = draw_color * texture_color;

    int index =
        actual_color.a == 0.0                ? 0 :
        actual_color == vec4(vec3(0.0), 1.0) ? 1 :
        actual_color != vec4(1.0)            ? 2 :
                                               3 ;

    return palette[index];
}
