//
//  NezSCNViewController.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/10.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "NezAletterationInputControllers.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationBulletPhysics.h"
#import "NezAnimator.h"

#define NEZ_ALETTERATION_CAMERA_BIG_BOX @"BIG_BOX"

#define NEZ_ALETTERATION_CAMERA_PLAYER0_GAMEBOARD @"PLAYER0_GAMEBOARD"
#define NEZ_ALETTERATION_CAMERA_PLAYER1_GAMEBOARD @"PLAYER1_GAMEBOARD"
#define NEZ_ALETTERATION_CAMERA_PLAYER2_GAMEBOARD @"PLAYER2_GAMEBOARD"
#define NEZ_ALETTERATION_CAMERA_PLAYER3_GAMEBOARD @"PLAYER3_GAMEBOARD"

#define NEZ_ALETTERATION_CAMERA_PLAYER0_STARTING @"PLAYER0_STARTING"
#define NEZ_ALETTERATION_CAMERA_PLAYER1_STARTING @"PLAYER1_STARTING"
#define NEZ_ALETTERATION_CAMERA_PLAYER2_STARTING @"PLAYER2_STARTING"
#define NEZ_ALETTERATION_CAMERA_PLAYER3_STARTING @"PLAYER3_STARTING"

#define NEZ_ALETTERATION_CAMERA_PLAYER0_RETIRED_WORDS @"PLAYER0_RETIRED_WORDS"
#define NEZ_ALETTERATION_CAMERA_PLAYER1_RETIRED_WORDS @"PLAYER1_RETIRED_WORDS"
#define NEZ_ALETTERATION_CAMERA_PLAYER2_RETIRED_WORDS @"PLAYER2_RETIRED_WORDS"
#define NEZ_ALETTERATION_CAMERA_PLAYER3_RETIRED_WORDS @"PLAYER3_RETIRED_WORDS"

#define NEZ_ALETTERATION_CAMERA_FULL_OVERVIEW @"FULL_OVERVIEW"

@interface NezAletterationSCNView : SCNView<NSWindowDelegate, SCNSceneRendererDelegate>

@property (setter = setInputController:, getter = inputController) NezAletterationInputController *inputController;
@property (readonly, getter = graphics) NezAletterationGraphics *graphics;
@property (readonly, getter = physics) NezAletterationBulletPhysics *physics;
@property (readonly, getter = kinematicsAnimator) NezAnimator *kinematicsAnimator;
@property (readonly, getter = notificationCenter) NSNotificationCenter *notificationCenter;

-(CVReturn)stepFrameForTime:(const CVTimeStamp*)outputTime;

-(BOOL)setCameraForName:(NSString*)cameraName;
-(void)animateToCameraForName:(NSString*)cameraName withDuration:(CFTimeInterval)duration andCompletionBlock:(NezVoidBlock)completionHandler;
-(void)animateToRandomCameraWithCompletionHandler:(NezVoidBlock)completionHandler;

@end
