//
//  Texture.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec4 a_position;
attribute vec2 a_uv;

//Instance Attributes
attribute vec4 a_matrixColumn0;
attribute vec4 a_matrixColumn1;
attribute vec4 a_matrixColumn2;
attribute vec4 a_matrixColumn3;

//Uniforms
uniform mat4 u_modelViewProjectionMatrix;

//varrying out to fragment shader
varying vec2 v_uv;

void main() {
	mat4 modelMatrix = mat4(a_matrixColumn0, a_matrixColumn1, a_matrixColumn2, a_matrixColumn3);
	vec4 pos = modelMatrix * a_position;
	v_uv = a_uv;
	gl_Position = u_modelViewProjectionMatrix * pos;
}