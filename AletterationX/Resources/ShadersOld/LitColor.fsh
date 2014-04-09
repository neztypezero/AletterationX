//
//  LitColor.fsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

uniform highp vec3 u_lightDirection;

varying highp vec3 v_normal;
varying highp vec4 v_color;

void main()
{
	highp float diffuseValue = max(dot(v_normal, u_lightDirection), 0.0);
	gl_FragColor = v_color * diffuseValue;
}
