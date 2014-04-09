//
//  NezFogVAO.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"

@class NezVertex2VBO;
@class NezGLSLProgramFog;

@interface NezFogVAO : NezVertexArrayObject

@property (getter = program, setter = setProgram:) NezGLSLProgramFog *program;
@property (readonly, getter = vertexBufferObject) NezVertex2VBO *vertexBufferObject;

@property GLKVector2 uvRatio;
@property GLKVector4 fogColor;
@property GLuint colorTexture;
@property GLuint depthTexture;

@end
