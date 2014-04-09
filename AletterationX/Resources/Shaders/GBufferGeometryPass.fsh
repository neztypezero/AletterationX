//
//  GBufferGeometryPass.fsh
//  AletterationX
//
//  Created by David Nesbitt on 2014-02-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#version 410

in vec2 v_uv;
in vec3 v_normal;
in vec3 v_position;

layout (location = 0) out vec3 out_position;
layout (location = 1) out vec3 out_diffuse;
layout (location = 2) out vec3 out_normal;

uniform sampler2D u_texture0;

void main() {
	out_position = v_position;
	out_diffuse = texture(u_texture0, v_uv).xyz;
	out_normal = normalize(v_normal);
}