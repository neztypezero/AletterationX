//
//  NezParticleSystemVAO.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"

@class NezVertexParticleVBO;
@class NezGLSLProgramParticleSystem;

@interface NezParticleSystemVAO : NezVertexArrayObject

@property (getter = program, setter = setProgram:) NezGLSLProgramParticleSystem *program;
@property (readonly, getter = vertexBufferObject) NezVertexParticleVBO *vertexBufferObject;

@property GLuint tex;
@property GLuint ramp;

@property GLenum srcBlend;
@property GLenum dstBlend;

@property BOOL enableZRead;
@property BOOL enableZWrite;

@property GLKMatrix4 mv;
@property GLKMatrix4 proj;

@property float trailFactor;
@property GLsizei liveParticlesCount;

@end
