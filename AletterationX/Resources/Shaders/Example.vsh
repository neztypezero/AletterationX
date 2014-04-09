//
//  Example.vsh
//  AletterationX
//
//  Created by David Nesbitt on 2014-02-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#version 410

layout (location = 0) in vec2 a_position;

uniform vec2 u_uvRatio;

out vec2 v_uv;

void main(void) {
	v_uv = ((a_position.xy + 1.0) * 0.5) * u_uvRatio;
	gl_Position = vec4(a_position, 0.0, 1.0);
}