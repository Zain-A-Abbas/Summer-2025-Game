shader_type spatial;
render_mode shadows_disabled, ambient_light_disabled, unshaded;

uniform sampler2D slash_texture: repeat_disable;
uniform sampler2D slash_curve;
uniform sampler2D slash_alpha;
uniform sampler2D dissolve;
uniform sampler2D dissolve_curve;
instance uniform float lifetime: hint_range(0.01, 0.99, 0.01) = 0.99;


void vertex() {
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
