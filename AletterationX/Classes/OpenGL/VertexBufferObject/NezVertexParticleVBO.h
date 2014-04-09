//
//  NezVertexParticleVBO.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertexParticleVBO : NezVertexBufferObject

@property (readonly, getter = vertexList) NezVertexParticle *vertexList;

@end
