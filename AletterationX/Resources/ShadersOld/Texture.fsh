//
//  Texture.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

uniform highp sampler2D u_texture0;

varying highp vec2 v_uv;

void main()
{
	highp vec4 texel = texture2D(u_texture0, v_uv);
	gl_FragColor = (gl_LastFragData[0]*(1.0-texel.a)) + (texel*texel.a);
}
