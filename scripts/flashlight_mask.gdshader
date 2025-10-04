shader_type canvas_item;
render_mode world_vertex_coords;

global uniform vec2 mouse_pos;
uniform float flashlight_distance = 100.0;
varying vec2 vertex_pos;


void vertex() {
	//vertex_pos = ((PROJECTION_MATRIX * WORLD_MATRIX) * vec4(VERTEX, 0.0, 1.0) * inverse(PROJECTION_MATRIX)).xy;
	vertex_pos = VERTEX;
}

void fragment() {
	float dist = sqrt(pow(vertex_pos.x-mouse_pos.x, 2) + pow(vertex_pos.y-mouse_pos.y, 2));
	if (dist > flashlight_distance){
		COLOR = vec4(0,0,0,255);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
