shader_type canvas_item;

uniform float radius : hint_range(0.01, 0.2) = 0.05;
uniform float ring_radius : hint_range(0.1, 1.0) = 0.2;
uniform float speed : hint_range(0.1, 10.0) = 1.0;
uniform int count : hint_range(1, 32) = 9;
uniform float fade_power : hint_range(1.0, 10.0) = 1.2;
uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float background_alpha : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    // UV من -1 إلى 1
    vec2 uv = (UV - vec2(0.5)) * 2.0;

    // تصحيح نسبة العرض إلى الارتفاع
    uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.y;
    uv.y /= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.y + 0.5;

    float alpha = 0.0;
    float head = fract(TIME * speed) * float(count);

    for (int i = 0; i < count; i++) {
        float angle = float(i) * 2.0 * PI / float(count);
        vec2 center = vec2(cos(angle), sin(angle)) * ring_radius;

        float dist = distance(uv, center);
        float circle = smoothstep(radius, radius - 0.01, dist);

        float offset = mod(float(i) - head + float(count), float(count));
        float fade = 1.0 - exp(-fade_power * (1.0 - offset / float(count)));
        fade = 1.0 - fade;

        alpha += circle * fade;
    }

    float background = background_alpha;
    vec3 final_color = mix(vec3(0.0, 0.0, 0.0), circle_color.rgb, alpha);
    float final_alpha = max(background, alpha * circle_color.a);

    COLOR = vec4(final_color, final_alpha);
}
