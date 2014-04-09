//
//  LitColorTexture.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec4 a_position;
attribute vec3 a_normal;
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
attribute vec4 a_modelColor;

//Uniforms
uniform mat3 u_normalMatrix;
uniform mat4 u_modelViewProjectionMatrix;

//varrying out to fragment shader
varying vec3 v_normal;
varying vec4 v_color;
varying vec2 v_uv;

void main() {
	mat4 modelMatrix = mat4(a_matrixColumn0, a_matrixColumn1, a_matrixColumn2, a_matrixColumn3);
	vec4 pos = modelMatrix * a_position;
	vec3 normal = (modelMatrix * vec4(a_normal, 0.0)).xyz;
	
    v_normal = normalize(u_normalMatrix * normal);
	v_color = a_modelColor;

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
	gl_Position = u_modelViewProjectionMatrix * pos;
}