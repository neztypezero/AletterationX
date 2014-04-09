//
//  NezAnimation.m
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@implementation NezAnimation

-(instancetype)initWithFromData:(float*)fromDataPtr ToData:(float*)toDataPtr DataLength:(int)length Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	if ((self = [super init])) {
		_dataLength = length/sizeof(float);
		_data = [NSMutableData dataWithLength:length*3];
		
		_fromData = (float*)[_data bytes];
		memcpy(_fromData, fromDataPtr, length);
		_toData = &_fromData[_dataLength];
		memcpy(_toData, toDataPtr, length);
		_newData = &_fromData[_dataLength*2];

		_easingFunction = func;
		
		_duration = d;
		_repeatCount = 0;
		_delay = 0;
		
		_cancelled = NO;
		_removedWhenFinished = YES;
		
		_loop = NEZ_ANI_NO_LOOP;
		
		self.updateFrameBlock = updateBlock;
		self.didStopBlock = didStopBlock;
	}
	return self;
}

-(instancetype)initFloatWithFromData:(float)from ToData:(float)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:&from ToData:&to DataLength:sizeof(float) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(instancetype)initVec2WithFromData:(GLKVector2)from ToData:(GLKVector2)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.v ToData:to.v DataLength:sizeof(GLKVector2) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(instancetype)initVec3WithFromData:(GLKVector3)from ToData:(GLKVector3)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.v ToData:to.v DataLength:sizeof(GLKVector3) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(instancetype)initVec4WithFromData:(GLKVector4)from ToData:(GLKVector4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.v ToData:to.v DataLength:sizeof(GLKVector4) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(instancetype)initMat4WithFromData:(GLKMatrix4)from ToData:(GLKMatrix4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [self initWithFromData:from.m ToData:to.m DataLength:sizeof(GLKMatrix4) Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock];
}

-(void)runToElapsedTime {
	for (int i=0; i<_dataLength; i++) {
		if (_toData[i] == _fromData[i]) {
			_newData[i] = _toData[i];
		} else {
			_newData[i] = _easingFunction(_elapsedTime, _fromData[i], _toData[i]-_fromData[i], _duration);
		}
	}
}

-(NSTimeInterval)getT {
	return _elapsedTime/_duration;
}

-(void)pingPongAnimation {
	_elapsedTime = -_delay;
	
	float *toData = _fromData;
	float *fromData = _toData;
	
	_toData = toData;
	_fromData = fromData;
}

-(void)dealloc {
	self.chainLink = nil;
	self.updateFrameBlock = nil;
	self.didStopBlock = nil;
	_data = nil;
}

@end
