shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.38, 0.46, 0.52, 1.0);
uniform float fog_strength : hint_range(0.0, 1.0) = 0.45;
uniform float night_strength : hint_range(0.0, 1.0) = 0.0;
uniform float warmth : hint_range(0.0, 1.0) = 0.25;
uniform float animation_time = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float vignette = smoothstep(0.18, 0.78, length(centered));
	vec2 drift = vec2(animation_time * 0.008, -animation_time * 0.004);
	float mist = value_noise(UV * vec2(5.0, 3.0) + drift);
	float grain = hash(floor(UV * vec2(480.0, 270.0)) + floor(animation_time * 2.0));

	vec3 cold_tint = mix(tint_color.rgb, vec3(0.16, 0.20, 0.27), night_strength * 0.45);
	vec3 warm_tint = vec3(0.88, 0.65, 0.34);
	vec3 graded = mix(cold_tint, warm_tint, warmth * 0.30);

	float fog_alpha = fog_strength * (0.035 + mist * 0.055);
	float night_alpha = night_strength * 0.075;
	float vignette_alpha = vignette * (0.025 + night_strength * 0.055);
	float grain_alpha = (grain - 0.5) * 0.012;
	float alpha = clamp(fog_alpha + night_alpha + vignette_alpha + grain_alpha, 0.0, 0.22);

	COLOR = vec4(graded, alpha);
}
