//
//  NezVboVertexP4T2.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/31.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVboVertexP4T2 : NezVertexBufferObject

@property (readonly, getter = vertexList) NezVertexP4T2 *vertexList;

@end
