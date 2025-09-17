shader_type canvas_item;

uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float drift_speed : hint_range(0.0, 2.0) = 0.5;

vec3 create_radial_gradient(vec2 uv, vec2 center, vec3 color, float radius, float time_offset) {
    // Add subtle movement to gradient centers
    vec2 animated_center = center + sin(TIME * drift_speed + time_offset) * 0.05;

    float dist = distance(uv, animated_center);

    // Animate the radius with pulsing effect
    float animated_radius = radius * (1.0 + sin(TIME * time_scale + time_offset) * pulse_intensity);

    // Create smooth falloff
    float falloff = smoothstep(0.0, animated_radius, dist);
    falloff = 1.0 - falloff;

    return color * falloff;
}

void fragment() {
    vec2 uv = UV;

    // Base background
    vec3 final_color = vec3(0.0);

    // First gradient: blue at top-left area (20%, 50%)
    vec3 blue_grad = create_radial_gradient(
        uv,
        vec2(0.2, 0.5),
        vec3(0.0, 0.588, 1.0) * 0.1,
        0.5,
        0.0
    );

    // Second gradient: magenta at top-right area (80%, 20%)
    vec3 magenta_grad = create_radial_gradient(
        uv,
        vec2(0.8, 0.2),
        vec3(1.0, 0.0, 0.588) * 0.1,
        0.5,
        2.094 // PI * 2/3 offset
    );

    // Third gradient: green at bottom area (40%, 80%)
    vec3 green_grad = create_radial_gradient(
        uv,
        vec2(0.4, 0.8),
        vec3(0.0, 1.0, 0.588) * 0.1,
        0.5,
        4.188 // PI * 4/3 offset
    );

    // Combine all gradients additively
    final_color = blue_grad + magenta_grad + green_grad;

    // Add subtle overall animation
    final_color *= (1.0 + sin(TIME * time_scale * 0.5) * 0.1);

    COLOR = vec4(final_color, 1.0);
}