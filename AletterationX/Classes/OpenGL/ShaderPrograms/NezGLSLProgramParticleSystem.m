//
//  NezGLSLProgramParticleSystem.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgramParticleSystem.h"

@implementation NezGLSLProgramParticleSystem

+(instancetype)program {
	return [self programWithShaderName:@"ParticleSystem"];
}

-(void)configureGeometryShader {
	GLuint program = self.program;
	glProgramParameteri(program, GL_GEOMETRY_INPUT_TYPE, GL_TRIANGLES);
	glProgramParameteri(program, GL_GEOMETRY_OUTPUT_TYPE, GL_TRIANGLE_STRIP);
	glProgramParameteri(program, GL_GEOMETRY_VERTICES_OUT, 4);
}

-(void)loadAttributesAndUniforms {
	GLuint program = self.program;

	_a_pos = glGetAttribLocation(program, "a_pos");
	_a_vel = glGetAttribLocation(program, "a_vel");
	_a_uv = glGetAttribLocation(program, "a_uv");

	_u_mv = glGetUniformLocation(program, "u_mv");
	_u_tex = glGetUniformLocation(program, "u_tex");
	_u_ramp = glGetUniformLocation(program, "u_ramp");
	_u_p = glGetUniformLocation(program, "u_p");
	_u_trailFactor = glGetUniformLocation(program, "u_trailFactor");
}

@end
