//
//  NezGLSLProgramFog.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgramFog.h"

@implementation NezGLSLProgramFog

+(instancetype)program {
	return [self programWithShaderName:@"Fog"];
}

-(void)loadAttributesAndUniforms {
	GLuint program = self.program;

	_a_position = glGetAttribLocation(program, "a_position");

	_u_uvRatio = glGetUniformLocation(program, "u_uvRatio");
	_u_colorTexture = glGetUniformLocation(program, "u_colorTexture");
	_u_depthTexture = glGetUniformLocation(program, "u_depthTexture");
	_u_fogColor = glGetUniformLocation(program, "u_fogColor");
}

@end
