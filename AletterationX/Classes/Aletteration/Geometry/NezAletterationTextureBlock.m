//
//  NezAletterationTextureBlock.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationTextureBlock.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezVertexBufferObjectTextureVertex.h"
#import "NezVertexArrayObjectTexture.h"

@interface NezAletterationTextureBlock() {
	NezVertexArrayObjectTexture *_vao;
}

@end

@implementation NezAletterationTextureBlock

-(instancetype)initWithVao:(NezVertexArrayObjectTexture*)vao {
	if (_vao && (self = [super init])) {
		_vao = vao;
		_dimensions = _vao.vertexBufferObject.dimensions;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeObject:_vao forKey:@"_vao"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_vao = [coder decodeObjectForKey:@"_vao"];
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_vao.modelMatrix = modelMatrix;
	[super setModelMatrix:modelMatrix];
}

-(void)setCenter:(GLKVector3)center {
	[super setCenter:center];
	_vao.modelMatrix = _modelMatrix;
}

-(void)setUV0:(GLKVector2)uv0 UV1:(GLKVector2)uv1 UV2:(GLKVector2)uv2 UV3:(GLKVector2)uv3 {
}

@end
