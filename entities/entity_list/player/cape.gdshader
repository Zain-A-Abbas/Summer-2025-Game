shader_type spatial;
render_mode cull_disabled;

global uniform vec3 wind_direction;
global uniform float wind_speed;
global uniform float wind_intensity;

uniform sampler2D intensity_vertex;
uniform sampler2D wind_noise_texture;

float get_position_sum(vec3 world_position) {
	return world_position.x + world_position.y + world_position.z;
}

void vertex() {
float position_sum = get_position_sum(NODE_POSITION_WORLD);

	vec3 model_front_direction = vec3(0.0, 0.0, 1.0);
	vec3 model_side_direction = vec3(1.0, 0.0, 0.0);

	float vertex_color_mask = texture(intensity_vertex, UV).r;
	if (UV.y < 0.2) {
		vertex_color_mask = 0.0;
	}

	mat3 inv_model_matrix = inverse(mat3(MODEL_MATRIX));
	vec3 wind_local_direction = normalize(inv_model_matrix * wind_direction);

	float dot_product = dot(model_front_direction, wind_local_direction);
	float side_dot = dot(model_side_direction, wind_local_direction);

	float strength = -abs(dot_product);
	float push_strength = clamp(strength, 0.01, 1.0);
	float noise_strength = clamp(strength, 0.5, 1.0);

	float scroll_direction = -1.0 * sign(side_dot);
	float scroll_speed = wind_speed;

	float wind_uv_scale = 0.1;
	float wind_object_offset = position_sum * 0.2;

	vec2 wind_uv = vec2(
		VERTEX.x * wind_uv_scale + TIME * scroll_speed * scroll_direction + wind_object_offset,
		VERTEX.y * wind_uv_scale
	);

	float wind_noise = texture(wind_noise_texture, wind_uv).r;

	// Unpack wind noise, from 0 - 1 range, to -1 1 range
	wind_noise = 2.0 * wind_noise - 1.0;

	VERTEX += wind_local_direction * wind_intensity * push_strength * vertex_color_mask;
	VERTEX.z += wind_noise * 0.5 * wind_intensity * noise_strength * vertex_color_mask;
}

void fragment() {
	ALBEDO.rgb = vec3(1.0, 0.0, 0.0);
	//ALBEDO.r = 1.0 * (texture(intensity_vertex, UV).r);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
