//
//  BlitTexture.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

precision highp float;

uniform sampler2D u_texture0;

varying vec2 v_uv;

void main () {
	gl_FragColor = texture2D(u_texture0, v_uv);
}