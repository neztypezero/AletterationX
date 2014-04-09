//
//  FullScreenQuad.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

attribute vec4 a_position;
attribute vec2 a_uv;

varying vec2 v_uv;

void main () {
	v_uv = a_uv;
	gl_Position = a_position;
}