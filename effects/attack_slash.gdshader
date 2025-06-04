shader_type spatial;

uniform sampler2D slash_texture: repeat_disable;
uniform sampler2D slash_curve;
uniform sampler2D slash_alpha;
uniform sampler2D dissolve;
uniform sampler2D dissolve_curve;
uniform float lifetime_test: hint_range(0.01, 0.99, 0.01) = 0.0;

varying float lifetime;

void vertex() {
	lifetime = max(0.01, INSTANCE_CUSTOM.y);
	lifetime = min(0.99, lifetime);
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 slash_curve_tx = texture(slash_curve, vec2(lifetime, 0.0));
	vec4 slash_al = texture(slash_alpha, UV);
	float slash_uv = slash_curve_tx.r;
	vec4 slash_tx = texture(slash_texture, vec2(UV.x - slash_uv, UV.y));
	vec4 dissolve_tx = texture(dissolve, UV);
	vec4 dissolve_curve_tx = texture(dissolve_curve, vec2(lifetime, 0.0));
	
	float dissolve_threshold = dissolve_curve_tx.r;
	
	ALPHA = slash_tx.a * slash_al.r;
	
	if (dissolve_tx.r < dissolve_threshold) {
		ALPHA = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
