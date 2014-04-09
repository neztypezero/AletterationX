//
//  NezVertex2VBO.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertex2VBO : NezVertexBufferObject

@property (readonly, getter = vertexList) NezVertex2 *vertexList;

@end
