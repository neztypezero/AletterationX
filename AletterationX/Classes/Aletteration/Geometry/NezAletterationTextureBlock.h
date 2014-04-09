//
//  NezAletterationTextureBlock.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexArrayObjectTexture;

@interface NezAletterationTextureBlock : NezAletterationRestorableGeometry

@property (getter = getColor, setter = setColor:) GLKVector4 color;

-(instancetype)initWithVao:(NezVertexArrayObjectTexture*)vao;

-(void)setUV0:(GLKVector2)uv0 UV1:(GLKVector2)uv1 UV2:(GLKVector2)uv2 UV3:(GLKVector2)uv3;

@end
