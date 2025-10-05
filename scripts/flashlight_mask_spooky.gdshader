shader_type canvas_item;
render_mode world_vertex_coords;

global uniform vec2 mouse_pos;
global uniform bool is_dark = false;
global uniform bool flashlight_on = false;
global uniform sampler2D point_light_dithered;
uniform float flashlight_distance = 500.0;
uniform vec4 dark_color = vec4(0, 0.016, 0.071, 1);
varying vec2 vertex_pos;


void vertex() {
	//vertex_pos = ((PROJECTION_MATRIX * WORLD_MATRIX) * vec4(VERTEX, 0.0, 1.0) * inverse(PROJECTION_MATRIX)).xy;
	vertex_pos = VERTEX;
}

void fragment() {
	if (is_dark) {
		if (flashlight_on){
			float dist = sqrt(pow(vertex_pos.x-mouse_pos.x, 2) + pow(vertex_pos.y-mouse_pos.y, 2));
			if (dist > flashlight_distance){
				COLOR = vec4(0,0,0,0);
			} else {
				vec2 uv = vec2((vertex_pos.x-mouse_pos.x)/flashlight_distance/3.0 + 0.5, (vertex_pos.y-mouse_pos.y)/flashlight_distance/3.0 + 0.5);
				float light_alpha = 0.0;
				if (texture(point_light_dithered, uv).r > 0.5) {
					light_alpha = 1.0;
				}
				COLOR.a = light_alpha;
				//COLOR = COLOR * pow((flashlight_distance-dist)/flashlight_distance,2);
			}
		} else {
			COLOR = vec4(0,0,0,0);
		}
		
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
