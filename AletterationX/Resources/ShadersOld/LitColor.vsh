//
//  LitColor.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec4 a_matrixColumn0;
attribute vec4 a_matrixColumn1;
attribute vec4 a_matrixColumn2;
attribute vec4 a_matrixColumn3;
attribute vec4 a_modelColor;

uniform mat3 u_normalMatrix;
uniform mat4 u_modelViewProjectionMatrix;

varying vec3 v_normal;
varying vec4 v_color;

void main() {
	mat4 modelMatrix = mat4(a_matrixColumn0, a_matrixColumn1, a_matrixColumn2, a_matrixColumn3);
	vec4 pos = modelMatrix * a_position;
	vec3 normal = (modelMatrix * vec4(a_normal, 0.0)).xyz;

	v_normal = normalize(u_normalMatrix * normal);
	v_color = a_modelColor;

	gl_Position = u_modelViewProjectionMatrix * pos;
}