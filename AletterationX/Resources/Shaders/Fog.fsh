//
//  Fog.fsh
//  AletterationX
//
//  Created by David Nesbitt on 2014-02-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#version 410

uniform sampler2D u_colorTexture;
uniform sampler2D u_depthTexture;
uniform vec4 u_fogColor;

in vec2 v_uv;

out vec4 outputFragColor;

void main (void) {
	float fog = texture(u_depthTexture, v_uv).r;

	float fogStart = 0.998;
	float fogEnd = 1.0;
	float fogFactor = 1.0;

	fog = smoothstep(fogStart, fogEnd, fog) * fogFactor;

	outputFragColor =	texture(u_colorTexture, v_uv) * (1.0-fog) + u_fogColor*fog;
	
//	vec3 color = texture2D(u_colorTexture, v_uv).rgb;
//	vec3 color = FXAA(u_colorTexture, vec2(2560, 1440), v_uv);
//	gl_FragColor.rgb = color * (1.0-fog) + u_fogColor.rgb*fog;
}

