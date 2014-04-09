//
//  BlurHorizontal.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

precision highp float;

uniform float u_blurRadius;
uniform sampler2D u_texture0;

varying vec2 v_uv;

void main () {
	vec4 sum = vec4(0.0);
	
	sum += texture2D(u_texture0, vec2(v_uv.x - 4.0*u_blurRadius, v_uv.y)) * 0.05;
	sum += texture2D(u_texture0, vec2(v_uv.x - 3.0*u_blurRadius, v_uv.y)) * 0.09;
	sum += texture2D(u_texture0, vec2(v_uv.x - 2.0*u_blurRadius, v_uv.y)) * 0.12;
	sum += texture2D(u_texture0, vec2(v_uv.x - u_blurRadius, v_uv.y)) * 0.15;
	sum += texture2D(u_texture0, vec2(v_uv.x, v_uv.y)) * 0.16;
	sum += texture2D(u_texture0, vec2(v_uv.x + u_blurRadius, v_uv.y)) * 0.15;
	sum += texture2D(u_texture0, vec2(v_uv.x + 2.0*u_blurRadius, v_uv.y)) * 0.12;
	sum += texture2D(u_texture0, vec2(v_uv.x + 3.0*u_blurRadius, v_uv.y)) * 0.09;
	sum += texture2D(u_texture0, vec2(v_uv.x + 4.0*u_blurRadius, v_uv.y)) * 0.05;
	
	gl_FragColor = sum;
}