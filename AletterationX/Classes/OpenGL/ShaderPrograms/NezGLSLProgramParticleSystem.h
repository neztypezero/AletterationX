//
//  NezGLSLProgramParticleSystem.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgram.h"

@interface NezGLSLProgramParticleSystem : NezGLSLProgram<NezAttribute_pos,NezAttribute_vel,NezAttribute_uv>

@property (readonly) GLint a_pos;
@property (readonly) GLint a_vel;
@property (readonly) GLint a_uv;
@property (readonly) GLint u_mv;
@property (readonly) GLint u_tex;
@property (readonly) GLint u_ramp;
@property (readonly) GLint u_p;
@property (readonly) GLint u_trailFactor;

+(instancetype)program;

@end
