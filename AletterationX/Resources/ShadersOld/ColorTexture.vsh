//
//  ColorTexture.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec4 a_position;
attribute float a_uvIndex;

//Instance Attributes
attribute vec4 a_matrixColumn0;
attribute vec4 a_matrixColumn1;
attribute vec4 a_matrixColumn2;
attribute vec4 a_matrixColumn3;
attribute vec2 a_uv0;
attribute vec2 a_uv1;
attribute vec2 a_uv2;
attribute vec2 a_uv3;
attribute vec4 a_color;

//Uniforms
uniform mat4 u_modelViewProjectionMatrix;

//varrying out to fragment shader
varying vec2 v_uv;
varying vec4 v_color;

void main() {
	mat4 modelMatrix = mat4(a_matrixColumn0, a_matrixColumn1, a_matrixColumn2, a_matrixColumn3);
	vec4 pos = modelMatrix * a_position;
	
	int index = int(a_uvIndex);
	if (index == 0) {
		v_uv = a_uv0;
	}
	if (index == 1) {
		v_uv = a_uv1;
	}
	if (index == 2) {
		v_uv = a_uv2;
	}
	if (index == 3) {
		v_uv = a_uv3;
	}
	v_color = a_color;
	gl_Position = u_modelViewProjectionMatrix * pos;
}