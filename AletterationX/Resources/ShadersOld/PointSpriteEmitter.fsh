//
//  PointSpriteEmitter.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

uniform highp sampler2D u_texture0;

varying highp vec4 v_color;

void main() {
	highp vec4 texel = texture2D(u_texture0, gl_PointCoord)*v_color;
	gl_FragColor = gl_LastFragData[0] + (texel*texel.a);
}
