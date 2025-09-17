shader_type canvas_item;

uniform float corner_radius: hint_range(0., 100.) = 15.0;
uniform float smoothness: hint_range(0.1, 10.0) = 5.0;
uniform vec2 texture_size = vec2(512.0, 512.0);

void fragment() {
    vec2 uv = UV;
    vec2 size = texture_size;

    // Convert corner radius from pixels to UV coordinates
    vec2 radius_uv = vec2(corner_radius) / size;

    // Calculate distance from corners
    vec2 corner_distances = vec2(0.0);

    // Bottom-left corner
    if (uv.x < radius_uv.x && uv.y < radius_uv.y) {
        corner_distances = (radius_uv - uv) / radius_uv;
    }
    // Bottom-right corner
    else if (uv.x > 1.0 - radius_uv.x && uv.y < radius_uv.y) {
        corner_distances = (vec2(uv.x - (1.0 - radius_uv.x), radius_uv.y - uv.y)) / radius_uv;
    }
    // Top-left corner
    else if (uv.x < radius_uv.x && uv.y > 1.0 - radius_uv.y) {
        corner_distances = (vec2(radius_uv.x - uv.x, uv.y - (1.0 - radius_uv.y))) / radius_uv;
    }
    // Top-right corner
    else if (uv.x > 1.0 - radius_uv.x && uv.y > 1.0 - radius_uv.y) {
        corner_distances = (uv - (1.0 - radius_uv)) / radius_uv;
    }

    // Calculate smooth alpha based on distance
    float distance = length(corner_distances);
    float alpha = 1.0 - smoothstep(1.0 - (smoothness / corner_radius), 1.0, distance);

    // Only apply alpha in corner regions
    if (corner_distances != vec2(0.0)) {
        COLOR.a *= alpha;
    }
}