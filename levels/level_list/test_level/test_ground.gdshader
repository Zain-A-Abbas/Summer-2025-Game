shader_type spatial;

varying vec3 world_position;

uniform vec3 points[5];

bool is_point_in_convex_polygon(vec3 position) {
	vec2 point = vec2(position.x, position.z);

	for (int i = 0; i < points.length(); i++) {
		vec3 a3 = points[i];
		vec3 b3 = points[(i + 1) % points.length()];

		vec2 a = vec2(a3.x, a3.z);
		vec2 b = vec2(b3.x, b3.z);

		vec2 edge = b - a;
		vec2 to_point = point - a;

		float cross = edge.x * to_point.y - edge.y * to_point.x;
		if (cross < 0.0) {
			return false;
		}
	}
	return true;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (is_point_in_convex_polygon(world_position)) {
		ALBEDO.g = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
