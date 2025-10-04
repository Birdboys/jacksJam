shader_type canvas_item;
render_mode world_vertex_coords;

varying vec2 vertex_pos;
void vertex() {
	//vertex_pos = ((PROJECTION_MATRIX * WORLD_MATRIX) * vec4(VERTEX, 0.0, 1.0) * inverse(PROJECTION_MATRIX)).xy;
	vertex_pos = VERTEX;
}

void fragment() {
	if (vertex_pos.x > 200.0){
		COLOR = vec4(255,0,0,255);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
