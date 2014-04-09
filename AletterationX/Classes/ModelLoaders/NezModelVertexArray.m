//
//  NezModelVertexArray.m
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezModelVertexArray.h"

@implementation NezModelVertexArray

+(instancetype)vertexArrayWithVertexCount:(int)vertexCount andIndexCount:(int)indexCount {
	return [[self alloc] initWithVertexCount:vertexCount andIndexCount:indexCount];
}

-(instancetype)initWithVertexCount:(int)vertexCount andIndexCount:(int)indexCount {
	if ((self = [super init])) {
		_vertexData = [NSMutableData dataWithLength:vertexCount*sizeof(NezModelVertex)];
		_vertexCount = vertexCount;
		
		_indexData = [NSMutableData dataWithLength:indexCount*sizeof(unsigned short)];
		_indexCount = indexCount;
		unsigned short *indexList = (unsigned short *)_indexData.bytes;
		for (int i=0; i<indexCount; i++) {
			indexList[i] = i;
		}
	}
	return self;
}

-(NSData*)getVertexData {
	return _vertexData;
}

-(NezModelVertex*)getVertexList {
	return (NezModelVertex*)_vertexData.bytes;
}

-(NSData*)getIndexData {
	return _indexData;
}

-(unsigned short*)getIndexList {
	return (unsigned short*)_indexData.bytes;
}

@end
