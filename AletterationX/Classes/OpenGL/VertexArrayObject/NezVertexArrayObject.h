//
//  NezVertexArrayObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@class NezVertexBufferObject;
@class NezGLSLProgram;

@interface NezVertexArrayObject : NSObject {
	NezGLSLProgram *_program;
	id _vertexBufferObject;
}

@property (readonly, getter = vertexArrayObject) GLuint vertexArrayObject;
@property (readonly, getter = vertexArrayObjectPtr) GLuint *vertexArrayObjectPtr;
@property (readonly, getter = vertexBufferObject) id vertexBufferObject;

@property (getter = program, setter = setProgram:) id program;

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject;

-(void)enableVertexAttributes;

-(void)draw;

@end
