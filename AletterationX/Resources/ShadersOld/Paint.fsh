//
//  DirectionalLightAmbientSpecularPerPixelTexture.vsh
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

precision highp float;

uniform sampler2D u_texture0;
uniform vec4 u_specular;
uniform float u_shininess;
uniform vec3 u_lightDirection; // camera space

varying vec4 v_diffuse;
varying vec3 v_normal;
varying vec3 v_eye;
varying vec2 v_uv;

void main() {
	// set the specular term to black
	vec4 spec = vec4(0.0);
	
	// normalize both input vectors
	vec3 n = normalize(v_normal);
	vec3 e = normalize(v_eye);
	
	float intensity = max(dot(n,u_lightDirection), 0.0);
	
	// compute the half vector
	vec3 h = normalize(u_lightDirection + e);
	// compute the specular term into spec
	float intSpec = max(dot(h,n), 0.0);
	spec = u_specular * pow(intSpec,u_shininess);
	
	vec4 texel = texture2D(u_texture0, v_uv);
	vec4 diffuse = (v_diffuse*(1.0-texel.a))+(texel*texel.a);
	gl_FragColor = max(intensity * diffuse + spec, diffuse*0.25);

	float flakeSize = 0.2;
	float flakeIntensity = 0.7;
	
	vec3 paintColor0 = vec3(0.9, 0.4, 0.3);
	vec3 paintColor1 = vec3(0.9, 0.75, 0.2);
	vec3 flakeColor = vec3(flakeIntensity);
	
	vec3 rnd = texel.rgb;
	rnd = normalize(2.0 * rnd - 1.0);

	vec3 nrm1 = normalize(0.05 * rnd + 0.95 * v_normal);
	vec3 nrm2 = normalize(0.3 * rnd + 0.4 * v_normal);

	float fresnel1 = clamp(dot(nrm1, v_eye*u_lightDirection), 0.0, 1.0);
	float fresnel2 = clamp(dot(nrm2, v_eye*u_lightDirection), 0.0, 1.0);

	vec3 col = mix(paintColor0, paintColor1, fresnel1);
	col += pow(fresnel2, 106.0) * flakeColor;

	gl_FragColor = vec4(col, 1.0)*v_diffuse;
}

/*
 float flakeSize = 0.2;
 float flakeIntensity = 0.7;
 
 vec3 paintColor0 = vec3(0.9, 0.4, 0.3);
 vec3 paintColor1 = vec3(0.9, 0.75, 0.2);
 vec3 flakeColor = vec3(flakeIntensity);
 
 vec3 rnd =  texture2D(u_diffuseTexture, _surface.diffuseTexcoord * vec2(1.0 / flakeSize)).rgb;
 rnd = normalize(2.0 * rnd - 1.0);
 
 vec3 nrm1 = normalize(0.05 * rnd + 0.95 * _surface.normal);
 vec3 nrm2 = normalize(0.3 * rnd + 0.4 * _surface.normal);
 
 float fresnel1 = clamp(dot(nrm1, _surface.view), 0.0, 1.0);
 float fresnel2 = clamp(dot(nrm2, _surface.view), 0.0, 1.0);
 
 vec3 col = mix(paintColor0, paintColor1, fresnel1);
 col += pow(fresnel2, 106.0) * flakeColor;
 
 _surface.normal = nrm1;
 _surface.diffuse = vec4(col, 1.0);
 _surface.emission = (_surface.reflective * _surface.reflective) * 2.0;
 _surface.reflective = vec4(0.0);

*/