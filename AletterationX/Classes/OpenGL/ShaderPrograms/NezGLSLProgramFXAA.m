//
//  NezGLSLProgramFXAA.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgramFXAA.h"

@implementation NezGLSLProgramFXAA

+(instancetype)program {
	return [self programWithShaderName:@"FXAA"];
}

-(void)loadAttributesAndUniforms {
	GLuint program = self.program;

	_a_position = glGetAttribLocation(program, "a_position");
	_a_uv = glGetAttribLocation(program, "a_uv");

	_u_texture0 = glGetUniformLocation(program, "u_texture0");
}

@end
