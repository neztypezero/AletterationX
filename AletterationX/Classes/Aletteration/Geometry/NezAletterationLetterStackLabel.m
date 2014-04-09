//
//  NezAletterationStackLabel.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterStackLabel.h"
#import "NezInstanceVertexArrayObjectColorTexture.h"
#import "NezVertexBufferObjectInstanceTextureVertex.h"
#import "NezAnimator.h"
#import "NezAnimation.h"

@interface NezAletterationLetterStackLabel() {
	NezInstanceVertexArrayObjectColorTexture *_labelVao;
	NSInteger _labelAttributeIndex;
	NezInstanceAttributeColorTexture *_labelAttributePtr;
}

@end

@implementation NezAletterationLetterStackLabel

-(instancetype)initWithLabelVao:(NezInstanceVertexArrayObjectColorTexture*)labelVao labelAttributeIndex:(NSInteger)labelAttributeIndex {
	if ((self = [super init]) && labelVao) {
		_labelVao = labelVao;
		_labelAttributeIndex = labelAttributeIndex;
		_labelAttributePtr = _labelVao.instanceAttributeList+_labelAttributeIndex;
		_dimensions = _labelVao.vertexBufferObject.dimensions;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeInteger:_count forKey:@"_count"];
	
	[coder encodeObject:_labelVao forKey:@"_labelVao"];
	[coder encodeInteger:_labelAttributeIndex forKey:@"_labelAttributeIndex"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_count = [coder decodeIntegerForKey:@"_count"];
	
	_labelVao = [coder decodeObjectForKey:@"_labelVao"];
	_labelAttributeIndex = [coder decodeIntegerForKey:@"_labelAttributeIndex"];
}

-(void)applicationFinishedRestoringState {
	_labelAttributePtr = _labelVao.instanceAttributeList+_labelAttributeIndex;
}

-(void)animateColor:(GLKVector4)color {
	__weak NezAletterationLetterStackLabel *myself = self;
	[NezAnimator animateVec4WithFromData:self.color ToData:color Duration:0.5 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		myself.color = (*(GLKVector4*)ani.newData);
	} DidStopBlock:^(NezAnimation *ani) {
	}];
}

-(GLKVector4)getColor {
	return _labelAttributePtr->color;
}

-(void)setColor:(GLKVector4)color {
	_labelAttributePtr->color = color;
}

-(void)setCount:(NSInteger)count {
	if (_count == 0 && count > 0) {
		GLKVector4 color = self.color;
		color.a = 1.0;
		[self animateColor:color];
	} else if (_count > 0 && count == 0) {
		GLKVector4 color = self.color;
		color.a = 0.0;
		[self animateColor:color];
	}
	if (_count != count) {
		_count = count;
		[self setUV];
	}
}

-(void)setUV {
	NSInteger x = _count%8;
	NSInteger y = 8-_count/8;

	float s = ((float)x)/8.0;
	float t = ((float)y)/8.0;
	float p = ((float)x+1)/8.0;
	float q = ((float)y-1)/8.0;
	
	_labelAttributePtr->uv0 = GLKVector2Make(p, t);
	_labelAttributePtr->uv1 = GLKVector2Make(s, t);
	_labelAttributePtr->uv2 = GLKVector2Make(s, q);
	_labelAttributePtr->uv3 = GLKVector2Make(p, q);
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_labelAttributePtr->matrix = modelMatrix;
	[super setModelMatrix:modelMatrix];
}

@end
