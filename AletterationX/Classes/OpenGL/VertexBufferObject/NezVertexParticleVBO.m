//
//  NezVertexParticleVBO.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexParticleVBO.h"
#import "NezGLSLProgram.h"

@implementation NezVertexParticleVBO

-(GLsizei)sizeofVertex {
	return sizeof(NezVertexParticle);
}

-(NezVertexParticle*)vertexList {
	return (NezVertexParticle*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(id<NezAttribute_pos,NezAttribute_vel,NezAttribute_uv>)program {
	[self enableVertexAttributeArrayWithLocation:program.a_pos size:4 stride:self.sizeofVertex offset:(void*)offsetof(NezVertexParticle, position)];
	[self enableVertexAttributeArrayWithLocation:program.a_vel size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezVertexParticle, velocity)];
	[self enableVertexAttributeArrayWithLocation:program.a_uv size:2 stride:self.sizeofVertex offset:(void*)offsetof(NezVertexParticle, uv)];
}

@end