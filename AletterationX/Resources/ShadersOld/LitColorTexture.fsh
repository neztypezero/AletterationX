//
//  LitColorTexture.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

uniform highp sampler2D u_texture;
uniform highp vec3 u_lightDirection;

varying highp vec3 v_normal;
varying highp vec4 v_color;
varying highp vec2 v_uv;

void main()
{
//	highp vec4 texel = texture2D(u_texture, v_uv);
//	highp vec3 color = (((v_color.rgb)*(1.0-texel.a))+(texel.rgb*texel.a));
//	gl_FragColor = vec4(color, 1.0);

	highp float diffuseValue = max(dot(v_normal, u_lightDirection), 0.0);
	gl_FragColor = v_color * diffuseValue;

}
