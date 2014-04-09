//
//  NezAletterationLid.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLid.h"
#import "NezInstanceAttributeBufferObjectColor.h"

@interface NezAletterationLid()  {
	NezInstanceAttributeBufferObjectColor *_instanceAbo;
	NSInteger _instanceAttributeIndex;
	NezInstanceAttributeColor *_instanceAttributePtr;
}

@end

@implementation NezAletterationLid

-(instancetype)initWithInstanceAbo:(NezInstanceAttributeBufferObjectColor*)instanceAbo index:(NSInteger)instanceAttributeIndex andDimensions:(GLKVector3)dimensions {
	if ((self = [super init])) {
		_instanceAbo = instanceAbo;
		_instanceAttributeIndex = instanceAttributeIndex;
		_instanceAttributePtr = _instanceAbo.instanceAttributeList+_instanceAttributeIndex;
		_dimensions = dimensions;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeObject:_instanceAbo forKey:@"_instanceAbo"];
	[coder encodeInteger:_instanceAttributeIndex forKey:@"_instanceAttributeIndex"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_instanceAbo = [coder decodeObjectForKey:@"_instanceAbo"];
	_instanceAttributeIndex = [coder decodeIntegerForKey:@"_instanceAttributeIndex"];
}

-(void)applicationFinishedRestoringState {
	_instanceAttributePtr = _instanceAbo.instanceAttributeList+_instanceAttributeIndex;
}

-(GLKVector4)getColor {
	return _instanceAttributePtr->color;
}

-(void)setColor:(GLKVector4)color {
	_instanceAttributePtr->color = color;
}

-(void)setCenter:(GLKVector3)center {
	[super setCenter:center];
	self.modelMatrix = _modelMatrix;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_instanceAttributePtr->matrix = modelMatrix;
	[super setModelMatrix:modelMatrix];
}

@end
