shader_type spatial;
render_mode cull_disabled;

global uniform vec3 wind;
global uniform float wind_intensity;

global uniform sampler2D wind_noise;

void vertex() {

}

void fragment() {
	ALBEDO.rgb = vec3(1.0, 0.0, 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
