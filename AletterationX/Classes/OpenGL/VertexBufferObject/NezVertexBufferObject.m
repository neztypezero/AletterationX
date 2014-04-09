//
//  NezVertexBufferObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"
#import "NezGLSLProgram.h"

@interface NezVertexBufferObject() {
	GLuint _vertexBufferObject;
	GLuint _indexBufferObject;
}

@end

@implementation NezVertexBufferObject

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super init])) {
		_vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:_vertexCount*self.sizeofVertex];
		
		_indexCount = vertexArray.indexCount;
		_indexData = [NSMutableData dataWithData:vertexArray.indexData];
		
		[self createBuffers];
	}
	return self;
}

-(instancetype)initWithVertexData:(NSData*)vertexData andIndexData:(NSData*)indexData {
	if ((self = [super init])) {
		if (self.sizeofVertex > 0 && (vertexData.length % self.sizeofVertex == 0)) {
			_vertexCount = (GLsizei)vertexData.length/self.sizeofVertex;
			_vertexData = [NSMutableData dataWithData:vertexData];
			
			_indexCount = (GLsizei)indexData.length/self.sizeofIndex;
			_indexData = [NSMutableData dataWithData:indexData];
			
			[self createBuffers];
		}
	}
	return self;
}

-(GLsizei)sizeofVertex {
	return 0;
}

-(GLsizei)sizeofIndex {
	return sizeof(unsigned short);
}

-(GLuint)vertexBufferObject {
	return _vertexBufferObject;
}

-(GLuint*)vertexBufferObjectPtr {
	return &_vertexBufferObject;
}

-(GLuint)indexBufferObject {
	return _indexBufferObject;
}

-(GLuint*)indexBufferObjectPtr {
	return &_indexBufferObject;
}

-(const void*)vertexList {
	return _vertexData.bytes;
}

-(unsigned short*)indexList {
	return (unsigned short*)_indexData.bytes;
}

-(void)createBuffers {
	[self deleteBuffers];
	glGenBuffers(1, &_vertexBufferObject);
	NSLog(@"glGenBuffers GL_ARRAY_BUFFER");
	glGenBuffers(1, &_indexBufferObject);
	NSLog(@"glGenBuffers GL_ELEMENT_ARRAY_BUFFER");
}

-(void)bindBufferData {
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
	NSLog(@"glBindBuffer GL_ARRAY_BUFFER");
	glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
	NSLog(@"glBufferData %lu", (long)_vertexData.length);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferObject);
	NSLog(@"glBindBuffer GL_ELEMENT_ARRAY_BUFFER");
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexData.length, _indexData.bytes, GL_STATIC_DRAW);
	NSLog(@"glBufferData %lu", (long)_indexData.length);
}

-(void)fillVertexData {
	glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferObject);
	glBufferSubData(GL_ARRAY_BUFFER, 0, _vertexData.length, _vertexData.bytes);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)deleteBuffers {
	if (_vertexBufferObject) {
		glDeleteBuffers(1, &_vertexBufferObject);
		_vertexBufferObject = 0;
	}
	if (_indexBufferObject) {
		glDeleteBuffers(1, &_indexBufferObject);
		_indexBufferObject = 0;
	}
}

-(void)enableVertexAttributesForProgram:(id)program {}

-(void)enableVertexAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride offset:(const GLvoid*)offset {
	if (location != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(location);
		NSLog(@"glEnableVertexAttribArray %d", location);
		glVertexAttribPointer(location, size, GL_FLOAT, GL_FALSE, stride, offset);
		NSLog(@"glVertexAttribPointer %d", location);
	}
}

-(void)dealloc {
	[self deleteBuffers];
}

@end
