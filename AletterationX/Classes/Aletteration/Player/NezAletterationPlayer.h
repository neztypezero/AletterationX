//
//  NezAletterationPlayer.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGCD.h"

@class NezAletterationGameBoard;
@class NezAletterationGameState;
@class NezAletterationLetterBlock;
@class NezAletterationPlayerPrefs;
@class NezAletterationGameController;

typedef void (^ NezAletteartionEndTurnHandler)(NSArray *letterBlockSetupContainerList);

@interface NezAletterationLetterBlockSetupContainer: NSObject

@property (readonly) NezAletterationLetterBlock *letterBlock;
@property (readonly) GLKVector3 originalPosition;
@property (readonly) GLKVector3 position;
@property (readonly) GLKQuaternion originalOrientation;
@property (readonly) GLKQuaternion orientation;
@property (readonly) SCNVector3 color;

+(instancetype)containerWithLetterBlock:(NezAletterationLetterBlock*)letterBlock Position:(GLKVector3)position Orientation:(GLKQuaternion)orientation Color:(SCNVector3)color;
-(instancetype)initWithLetterBlock:(NezAletterationLetterBlock*)letterBlock Position:(GLKVector3)position Orientation:(GLKQuaternion)orientation Color:(SCNVector3)color;

@end

@interface NezAletterationPlayer: NSObject

@property (nonatomic, strong) NezAletterationGameState *gameState;
@property (nonatomic, readonly) NezAletterationGameBoard *gameBoard;
@property (getter = getCurrentLetterBlock, setter = setCurrentLetterBlock:) NezAletterationLetterBlock *currentLetterBlock;
@property (nonatomic, getter = getPrefsPhoto, setter = setPrefsPhoto:) NSImage *prefsPhoto;
@property (nonatomic, getter = getPrefsName, setter = setPrefsName:) NSString *prefsName;
@property (nonatomic, getter = getPrefsNickName, setter = setPrefsNickName:) NSString *prefsNickName;
@property (nonatomic, getter = getPrefsColor, setter = setPrefsColor:) NSColor *prefsColor;
@property (nonatomic, getter = getPrefsIsLowerCase, setter = setPrefsIsLowerCase:) BOOL prefsIsLowerCase;
@property (readonly, getter = isGameOver) BOOL isGameOver;
@property (readonly, getter = hasTurnsRemaining) BOOL hasTurnsRemaining;
@property NSUInteger index;
@property NezAletterationGameController *gameController;

+(instancetype)player;

-(instancetype)init;
-(instancetype)initWithGameState:(NezAletterationGameState*)gameState;

-(void)startGame;
-(void)startTurn;
-(void)endTurnWithCompletionHandler:(NezAletteartionEndTurnHandler)completionHandler;

-(void)blockPlaced;
-(void)turnStarted;
-(void)turnEnded;
-(void)turnContinues;
-(void)retireWord;
-(void)doGameOver;

-(BOOL)isGameOver;
-(void)exitGame:(BOOL)isAnimated andCompletedHandler:(NezVoidBlock)completedHandler;

-(void)undoTurn;
-(void)animateUndoWithFinishedBlock:(NezVoidBlock)undoFinishedBlock;

@end

