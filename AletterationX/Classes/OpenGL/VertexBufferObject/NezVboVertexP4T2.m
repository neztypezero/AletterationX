//
//  NezVboVertexP4T2.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/31.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVboVertexP4T2.h"
#import "NezGLSLProgram.h"

@implementation NezVboVertexP4T2

-(GLsizei)sizeofVertex {
	return sizeof(NezVertexP4T2);
}

-(NezVertexP4T2*)vertexList {
	return (NezVertexP4T2*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(id<NezAttribute_position, NezAttribute_uv>)program {
	[self enableVertexAttributeArrayWithLocation:program.a_position size:4 stride:self.sizeofVertex offset:(void*)offsetof(NezVertexP4T2, position)];
	[self enableVertexAttributeArrayWithLocation:program.a_uv size:2 stride:self.sizeofVertex offset:(void*)offsetof(NezVertexP4T2, uv)];
}

@end
