//
//  PointLineEmitter.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec3 a_position;
attribute float a_growth;
attribute float a_stable;
attribute float a_decay;

//Uniforms
uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;
uniform vec2 u_screenSize;
uniform vec4 u_color0;
uniform vec4 u_color1;
uniform float u_time;
uniform float u_size;

//Out
varying vec4 v_color;

void main() {
	float life = a_growth+a_stable+a_decay;
	vec4 eyePos = u_modelViewMatrix * vec4(a_position, 1.0);
	vec4 projVoxel = u_projectionMatrix * vec4(u_size, u_size, eyePos.z, eyePos.w);
	vec2 projSize = u_screenSize * projVoxel.xy / projVoxel.w;
	gl_Position = u_projectionMatrix * eyePos;
	float alpha;
	if(u_time < a_growth) {
		gl_PointSize = 0.0;
		alpha = 0.0;
	} else if(u_time < a_growth+a_stable) {
		gl_PointSize = (0.025 * (projSize.x+projSize.y));
		alpha = 1.0;
	} else {
		float t = 1.0-clamp((u_time) / (life), 0.0, 1.0);
		gl_PointSize = t * (0.025 * (projSize.x+projSize.y));
		alpha = t;
	}
	float t = clamp((u_time) / (life), 0.0, 1.0);
	v_color = mix(u_color0, u_color1, t);
}