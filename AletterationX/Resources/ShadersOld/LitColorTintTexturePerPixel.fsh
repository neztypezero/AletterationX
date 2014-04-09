//
//  DirectionalLightAmbientSpecularPerPixelTexture.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

uniform highp sampler2D u_texture0;
uniform highp vec4 u_specular;
uniform highp float u_shininess;
uniform highp vec3 u_lightDirection; // camera space

varying highp vec4 v_diffuse;
varying highp vec3 v_normal;
varying highp vec3 v_eye;
varying highp vec2 v_uv;
varying highp vec4 v_tint;

void main() {
	// normalize both input vectors
	highp vec3 n = normalize(v_normal);
	highp vec3 e = normalize(v_eye);

	highp float intensity = max(dot(n, u_lightDirection), 0.0);

	// compute the half vector
	highp vec3 h = normalize(u_lightDirection + e);
	// compute the specular term into spec
	highp float intSpec = max(dot(h,n), 0.0);
	highp vec4 spec = u_specular * pow(intSpec, u_shininess);

	highp vec4 texel = texture2D(u_texture0, v_uv)*v_tint;
	highp vec4 diffuse = (v_diffuse*(1.0-texel.a))+(texel*texel.a);
	gl_FragColor = max(intensity * diffuse + spec, diffuse*NEZ_GLSL_DARKNESS_MULTIPLIER);

}