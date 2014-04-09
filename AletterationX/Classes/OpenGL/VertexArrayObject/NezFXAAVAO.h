//
//  NezFogVAO.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"

@class NezVboVertexP4T2;
@class NezGLSLProgramFXAA;

@interface NezFXAAVAO : NezVertexArrayObject

@property (getter = program, setter = setProgram:) NezGLSLProgramFXAA *program;
@property (readonly, getter = vertexBufferObject) NezVboVertexP4T2 *vertexBufferObject;

@property GLuint texture0;

@end
