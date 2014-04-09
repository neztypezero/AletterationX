//
// this is a Timothy Lottes FXAA 3.11
// check out the following link for detailed information:
// http://timothylottes.blogspot.ch/2011/07/fxaa-311-released.html
//
#version 150

// PARAMETERS
#define FXAA_QUALITY__PRESET 13

in vec2 v_uv;

uniform sampler2D u_texture0;

out vec4 outFragColor;

#include "SharedFunctions/FXAA.glsl"

void main() {
	outFragColor = vec4(FXAA(u_texture0, vec2(2560, 1440), v_uv), 1.0);
}