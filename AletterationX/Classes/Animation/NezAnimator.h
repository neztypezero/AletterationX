//
//  NezAnimator.h
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimationEasingFunction.h"
#import "NezAnimation.h"

@interface NezAnimator : NSObject {
	NSMutableArray *_animationList;
	NSMutableArray *_addedList;
	NSMutableArray *_removedList;
}

+(instancetype)animator;

-(NezAnimation*)animateFloatWithFromData:(float)from ToData:(float)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(NezAnimation*)animateVec2WithFromData:(GLKVector2)from ToData:(GLKVector2)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(NezAnimation*)animateVec3WithFromData:(GLKVector3)from ToData:(GLKVector3)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(NezAnimation*)animateVec4WithFromData:(GLKVector4)from ToData:(GLKVector4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;
-(NezAnimation*)animateMat4WithFromData:(GLKMatrix4)from ToData:(GLKMatrix4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

-(NezAnimation*)addAnimation:(NezAnimation*)animation;

-(void)removeAnimation:(NezAnimation*)animation;
-(void)removeAllAnimations;

-(void)cancelAnimation:(NezAnimation*)animation;

-(void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLastUpdate;

@end
