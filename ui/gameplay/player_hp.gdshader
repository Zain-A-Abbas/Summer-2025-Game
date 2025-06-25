shader_type canvas_item;

uniform sampler2D visibility_gradient;
uniform sampler2D noise;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 gradient_sampler = texture(visibility_gradient, UV);
	vec4 noise_sampler = texture(noise, UV);
	COLOR.a = gradient_sampler.r * noise_sampler.r;
	COLOR.rgb = vec3(0.9, 0.6, 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
