//
//  GBufferGeometryPass.vsh
//  AletterationX
//
//  Created by David Nesbitt on 2014-02-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#version 410

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec3 a_normal;
layout(location = 2) in vec2 a_uv;

out vec3 v_position;
out vec3 v_normal;
out vec2 v_uv;

uniform mat4 u_mvp;
uniform mat4 u_m;

void main() {
	v_uv = a_uv;
	v_normal = (u_m * vec4(a_normal, 0.0)).xyz;
	v_position = (u_m * vec4(a_position, 1.0)).xyz;
	gl_Position = u_mvp * vec4(a_position, 1.0);
}