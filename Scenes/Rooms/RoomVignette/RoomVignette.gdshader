shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Vignette color
uniform float inner_radius : hint_range(0.0, 1.0) = 0.3; // Inner radius for transparency
uniform float outer_radius : hint_range(0.0, 1.0) = 0.5; // Outer radius for vignette effect

void fragment() {
    vec2 uv = UV - vec2(0.5); // Centering UV coordinates
    float len = length(uv); // Distance from center

    // Calculate alpha based on distance
    float alpha = smoothstep(inner_radius, outer_radius, len);

    // Set the color with transparency
    COLOR = vec4(vignette_color.rgb, alpha * vignette_color.a);
}
