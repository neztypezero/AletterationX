//
//  NezVertex2VBO.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertex2VBO.h"
#import "NezGLSLProgram.h"

@implementation NezVertex2VBO

-(GLsizei)sizeofVertex {
	return sizeof(NezVertex2);
}

-(NezVertex2*)vertexList {
	return (NezVertex2*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(id<NezAttribute_position>)program {
	[self enableVertexAttributeArrayWithLocation:program.a_position size:2 stride:self.sizeofVertex offset:(void*)offsetof(NezVertex2, position)];
}

@end
