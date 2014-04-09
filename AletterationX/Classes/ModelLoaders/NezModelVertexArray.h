//
//  NezModelVertexArray.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef struct NezModelVertex {
	GLKVector3 position;
	GLKVector3 normal;
	GLKVector2 uv;
	GLKVector4 color;
} NezModelVertex;

@interface NezModelVertexArray : NSObject {
	NSMutableData *_vertexData;
	NSMutableData *_indexData;
}

@property (nonatomic, readonly, getter = getVertexData) NSData *vertexData;
@property (readonly) int vertexCount;
@property (nonatomic, readonly, getter = getVertexList) NezModelVertex *vertexList;

@property (nonatomic, readonly, getter = getIndexData) NSData *indexData;
@property (readonly) int indexCount;
@property (nonatomic, readonly, getter = getIndexList) unsigned short *indexList;

+(instancetype)vertexArrayWithVertexCount:(int)vertexCount andIndexCount:(int)indexCount;
-(instancetype)initWithVertexCount:(int)vertexCount andIndexCount:(int)indexCount;

@end
