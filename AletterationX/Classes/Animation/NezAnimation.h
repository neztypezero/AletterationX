//
//  NezAnimation.h
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimationEasingFunction.h"
#import <GLKit/GLKit.h>

typedef enum LOOP_TYPES {
	NEZ_ANI_NO_LOOP,
	NEZ_ANI_LOOP_FORWARD,
	NEZ_ANI_LOOP_PINGPONG,
} LOOP_TYPES;

@class NezAnimation;

typedef void (^NezAnimationBlock)(NezAnimation *ani);

@interface NezAnimation : NSObject {
	NSMutableData *_data;
	EasingFunctionPtr _easingFunction;
}

-(instancetype)initWithFromData:(float*)fromDataPtr ToData:(float*)toDataPtr DataLength:(int)length Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

-(instancetype)initFloatWithFromData:(float)from ToData:(float)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(instancetype)initVec2WithFromData:(GLKVector2)from ToData:(GLKVector2)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(instancetype)initVec3WithFromData:(GLKVector3)from ToData:(GLKVector3)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(instancetype)initVec4WithFromData:(GLKVector4)from ToData:(GLKVector4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(instancetype)initMat4WithFromData:(GLKMatrix4)from ToData:(GLKMatrix4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

@property (strong) NezAnimation *chainLink;
@property (copy) NezAnimationBlock updateFrameBlock;
@property (copy) NezAnimationBlock didStartBlock;
@property (copy) NezAnimationBlock didStopBlock;

@property (readonly) int dataLength;
@property (readonly) float *fromData;
@property (readonly) float *toData;
@property (readonly) float *newData;

@property (assign) NSTimeInterval delay;
@property (assign) int repeatCount;
@property (assign) BOOL cancelled;
@property (assign) BOOL removedWhenFinished;
@property (assign) LOOP_TYPES loop;
@property (readonly) NSTimeInterval duration;
@property (assign) NSTimeInterval elapsedTime;
@property (readonly, getter = getT) NSTimeInterval t;

-(void)runToElapsedTime;
-(void)pingPongAnimation;

@end
