//
//  NezGLSLProgramFog.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgram.h"

@interface NezGLSLProgramFog : NezGLSLProgram<NezAttribute_position>

@property (readonly) GLint a_position;
@property (readonly) GLint u_uvRatio;
@property (readonly) GLint u_colorTexture;
@property (readonly) GLint u_depthTexture;
@property (readonly) GLint u_fogColor;

+(instancetype)program;

@end
