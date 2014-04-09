//
//  NezVertexBufferObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "NezVertexTypes.h"
#import "NezModelVertexArray.h"

@class NezGLSLProgram;

@interface NezVertexBufferObject : NSObject {
	NSMutableData *_indexData;
	NSMutableData *_vertexData;
}

@property (readonly, getter = vertexBufferObject) GLuint vertexBufferObject;
@property (readonly, getter = vertexBufferObjectPtr) GLuint *vertexBufferObjectPtr;

@property (readonly, getter = indexBufferObject) GLuint indexBufferObject;
@property (readonly, getter = indexBufferObjectPtr) GLuint *indexBufferObjectPtr;

@property (readonly, getter = sizeofVertex) GLsizei sizeofVertex;
@property (readonly, getter = sizeofIndex) GLsizei sizeofIndex;

@property (readonly) GLsizei vertexCount;

@property (readonly) GLsizei indexCount;
@property (readonly, getter = indexList) unsigned short *indexList;

@property GLKVector3 dimensions;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray;
-(instancetype)initWithVertexData:(NSData*)vertexData andIndexData:(NSData*)indexData;

-(void)createBuffers;
-(void)bindBufferData;
-(void)fillVertexData;
-(void)deleteBuffers;

-(void)enableVertexAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride offset:(const GLvoid*)offset;

-(void)enableVertexAttributesForProgram:(id)program;

@end
