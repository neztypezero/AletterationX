//
// this is a Timothy Lottes FXAA 3.11
// check out the following link for detailed information:
// http://timothylottes.blogspot.ch/2011/07/fxaa-311-released.html
//

#version 150

in vec4 a_position;
in vec2 a_uv;

out vec2 v_uv;

void main() {
	v_uv = a_uv;
	gl_Position = a_position;
}