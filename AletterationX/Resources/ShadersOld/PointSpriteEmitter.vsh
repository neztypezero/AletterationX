//
//  PointSpriteEmitter.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec3 a_velocity;

//Uniforms
uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;
uniform vec2 u_screenSize;
uniform vec3 u_center;
uniform vec3 u_acceleration;
uniform vec4 u_color0;
uniform vec4 u_color1;
uniform float u_time;
uniform float u_growth;
uniform float u_decay;
uniform float u_size;

//Out
varying vec4 v_color;

void main() {
	vec3 position = u_center+(a_velocity*u_time)+(0.5*u_acceleration*u_time*u_time);
	vec4 eyePos = u_modelViewMatrix * vec4(position, 1.0);
	vec4 projVoxel = u_projectionMatrix * vec4(u_size, u_size, eyePos.z, eyePos.w);
	vec2 projSize = u_screenSize * projVoxel.xy / projVoxel.w;
	gl_Position = u_projectionMatrix * eyePos;
	
	float alpha = 1.0;
	if(u_time < u_growth) {
		gl_PointSize = 0.025 * (projSize.x+projSize.y);
	} else {
		float t = 1.0-((u_time - u_growth) / u_decay);
		gl_PointSize = t * (0.025 * (projSize.x+projSize.y));
		alpha = t;
	}
//	float t = clamp((u_time) / (u_growth+u_decay), 0.0, 1.0);
	v_color = vec4(1.0, 1.0, 1.0, 1.0);
}