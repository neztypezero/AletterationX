//
//  NezAletterationMainViewController.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/09.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationInputController.h"

@class NezAnimator;

@interface NezAletterationGameController : NezAletterationInputController

@property (readonly, getter = dynamicsQueue) dispatch_queue_t dynamicsQueue;
@property (readonly, getter = kinematicsAnimator) NezAnimator *kinematicsAnimator;
@property (readonly, getter = notificationCenter) NSNotificationCenter *notificationCenter;

@end
