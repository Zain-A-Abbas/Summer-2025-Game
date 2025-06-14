shader_type spatial;
render_mode shadows_disabled;

instance uniform bool hit_effect = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (hit_effect) {
		ALBEDO.rgb = vec3(1.0);
		ALPHA = 1.0;
	} else {
		ALPHA = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
