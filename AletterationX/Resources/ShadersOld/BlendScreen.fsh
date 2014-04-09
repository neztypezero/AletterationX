//
//  BlendScreen.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

precision highp float;

uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

varying vec2 v_uv;

void main ()
{
	vec4 dst = texture2D(u_texture0, v_uv);
	vec4 src = texture2D(u_texture1, v_uv);
	
	gl_FragColor = clamp((src + dst) - (src * dst), 0.0, 1.0);
	gl_FragColor.a = 1.0;
}