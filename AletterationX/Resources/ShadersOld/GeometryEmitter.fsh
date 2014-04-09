//
//  GeometryEmitter.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

varying highp vec4 v_color;

void main() {
	gl_FragColor = (gl_LastFragData[0]) + (v_color*v_color.a);
}
