//
//  NezGLSLProgramFXAA.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgram.h"

@interface NezGLSLProgramFXAA : NezGLSLProgram<NezAttribute_position>

@property (readonly) GLint a_position;
@property (readonly) GLint a_uv;
@property (readonly) GLint u_texture0;

+(instancetype)program;

@end
