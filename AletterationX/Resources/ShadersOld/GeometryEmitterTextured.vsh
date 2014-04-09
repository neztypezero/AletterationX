//
//  GeometryEmitter.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

//Vertex Attributes
attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_uv;

//Instance Attributes
attribute vec4 a_orientation;
attribute vec4 a_angularVelocity;
attribute vec4 a_color0;
attribute vec4 a_color1;
attribute vec3 a_velocity;
attribute vec3 a_offset;
attribute vec3 a_scale;
attribute vec2 a_uvScale;

//Uniforms
uniform mat4 u_modelViewProjectionMatrix;
uniform mat3 u_normalMatrix;
uniform float u_growth;
uniform float u_decay;
uniform float u_time;
uniform vec3 u_center;

//Out
varying vec4 v_color;
varying vec2 v_uv;

#include "SharedFunctions/Quaternion.glsl"

void main() {
	vec3 pos = a_position*a_scale;
	
	if(u_time < u_growth) {
		float t = (u_time / u_growth);
		pos *= t;
	} else {
		float t = 1.0-((u_time - u_growth) / u_decay);
		pos *= t;
	}
	
	vec4 orientation = normalize(a_orientation + (u_time*0.5)*QuaternionMultiply(a_angularVelocity, a_orientation));
	pos = u_center + QuaternionRotateVector(orientation, pos+a_offset);
	
	float t = (u_time / (u_growth + u_decay));
	v_color = mix(a_color0, a_color1, t);
	
	v_uv = a_uv*a_uvScale;
	
	gl_Position = u_modelViewProjectionMatrix * vec4(pos, 1.0);
}