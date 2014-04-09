//
//  BlendAdditive.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

precision highp float;

uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

varying vec2 v_uv;

void main () {
	vec4 dst = texture2D(u_texture0, v_uv);
	vec4 src = texture2D(u_texture1, v_uv);
	
	gl_FragColor = min(src + dst, 1.0);
}