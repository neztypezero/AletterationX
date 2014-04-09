//
//  NezVertexArrayObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"
#import "NezVertexBufferObject.h"
#import "NezGLSLProgram.h"

@interface NezVertexArrayObject() {
	GLuint _vertexArrayObject;
}

@end

@implementation NezVertexArrayObject

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject {
	if ((self = [super init])) {
		_vertexBufferObject = vertexBufferObject;
		[self createVertexArrayObject];
	}
	return self;
}

-(id)vertexBufferObject {
	return _vertexBufferObject;
}

-(GLuint)vertexArrayObject {
	return _vertexArrayObject;
}

-(GLuint*)vertexArrayObjectPtr {
	return &_vertexArrayObject;
}

-(NezGLSLProgram*)program {
	return _program;
}

-(void)setProgram:(NezGLSLProgram*)program {
	_program = program;
	
	if (_program) {
		glBindVertexArray(_vertexArrayObject);
		NSLog(@"glBindVertexArray");
		[_vertexBufferObject bindBufferData];
		[self enableVertexAttributes];
		glBindVertexArray(0);
	}
}

-(void)enableVertexAttributes {
	[_vertexBufferObject enableVertexAttributesForProgram:_program];
}

-(void)createVertexArrayObject {
	[self deleteVertexArrayObject];
	glGenVertexArrays(1, &_vertexArrayObject);
	NSLog(@"glGenVertexArrays");
}

-(void)deleteVertexArrayObject {
	if (self.vertexArrayObject) {
		glDeleteVertexArrays(1, &_vertexArrayObject);
		_vertexArrayObject = 0;
	}
}

-(void)draw {}

@end
