//
//  DirectionalLightAmbientSpecularPerPixelTexture.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec2 a_uv;

//Instance Attributes
attribute vec4 a_matrixColumn0;
attribute vec4 a_matrixColumn1;
attribute vec4 a_matrixColumn2;
attribute vec4 a_matrixColumn3;
attribute vec4 a_color;

//Uniforms
uniform mat4 u_modelViewProjectionMatrix;
uniform mat4 u_modelViewMatrix;
uniform mat3 u_normalMatrix;

//Out
varying vec3 v_normal;
varying vec4 v_color;
varying vec3 v_eye;
varying vec2 v_uv;

void main () {
	mat4 modelMatrix = mat4(a_matrixColumn0, a_matrixColumn1, a_matrixColumn2, a_matrixColumn3);
	vec4 position = modelMatrix * a_position;
	vec3 normal = (modelMatrix * vec4(a_normal, 0.0)).xyz;
	
	v_normal = normalize(u_normalMatrix * normal);
	v_eye = -((u_modelViewMatrix * position).xyz);

	v_uv = a_uv;
	v_color = a_color;

	gl_Position = u_modelViewProjectionMatrix * position;
}