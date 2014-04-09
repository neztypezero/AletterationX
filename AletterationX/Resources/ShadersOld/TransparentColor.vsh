//
//  TransparentColor.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

attribute vec4 a_position;
attribute vec4 a_matrixColumn0;
attribute vec4 a_matrixColumn1;
attribute vec4 a_matrixColumn2;
attribute vec4 a_matrixColumn3;
attribute vec4 a_color;

uniform mat4 u_modelViewProjectionMatrix;

varying vec4 v_color;

void main() {
	mat4 modelMatrix = mat4(a_matrixColumn0, a_matrixColumn1, a_matrixColumn2, a_matrixColumn3);
	vec4 pos = modelMatrix * a_position;
    
	v_color = a_color;
	gl_Position = u_modelViewProjectionMatrix * pos;
}