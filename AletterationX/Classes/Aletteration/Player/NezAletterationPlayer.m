//
//  NezAletterationPlayer.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGeometry.h"

#import "NezAletterationGraphics.h"

#import "NezAletterationPlayer.h"
#import "NezAletterationPlayerPrefs.h"
#import "NezAletterationGameStateLineState.h"
#import "NezAletterationSQLiteDictionary.h"

#import "NezAletterationGameState.h"
#import "NezAletterationGameStateLineState.h"
#import "NezAletterationGameStateLineStateStack.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationGameStateTurn.h"
#import "NezAletterationPlayerNotifications.h"
#import "NezAletterationGameController.h"

@implementation NezAletterationLetterBlockSetupContainer

+(instancetype)containerWithLetterBlock:(NezAletterationLetterBlock*)letterBlock Position:(GLKVector3)position Orientation:(GLKQuaternion)orientation Color:(SCNVector3)color {
	return [[self alloc] initWithLetterBlock:letterBlock Position:position Orientation:orientation Color:color];
}

-(instancetype)initWithLetterBlock:(NezAletterationLetterBlock*)letterBlock Position:(GLKVector3)position Orientation:(GLKQuaternion)orientation Color:(SCNVector3)color {
	if ((self = [super init])) {
		GLKTransform t = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(letterBlock.transform));
		_originalPosition = t.position;
		_originalOrientation = t.orientation;
		_letterBlock = letterBlock;
		_position = position;
		_orientation = orientation;
		_color = color;
	}
	return self;
}

@end

@interface NezAletterationPlayer() {
	NezAletterationPlayerPrefs *_prefs;
}

@end

@implementation NezAletterationPlayer

+(instancetype)player {
	return [[self alloc] init];
}

-(instancetype)init {
	return [self initWithGameState:[NezAletterationGameState gameState]];
}

-(instancetype)initWithGameState:(NezAletterationGameState*)gameState {
	if ((self = [super init])) {
		_gameState = gameState;
		_prefs = [[NezAletterationPlayerPrefs alloc] init];
		_gameBoard = [NezAletterationGraphics newGameBoard];
	}
	return self;
}

-(NSImage*)getPrefsPhoto {
	return _prefs.photo;
}

-(void)setPrefsPhoto:(NSImage*)photo {
	_prefs.photo = photo;
}

-(NSString*)getPrefsName {
	return _prefs.name;
}

-(void)setPrefsName:(NSString*)name {
	_prefs.name = name;
}

-(NSString*)getPrefsNickName {
	return _prefs.nickName;
}

-(void)setPrefsNickName:(NSString*)nickName {
	_prefs.nickName = nickName;
}

-(NSColor*)getPrefsColor {
	return _prefs.color;
}

-(void)setPrefsColor:(NSColor*)color {
	_prefs.color = color;
//	_gameBoard.color = _prefs.color;
	[_gameBoard setupLetterBlocksForGameState:_gameState isAnimated:NO];
}

-(BOOL)getPrefsIsLowerCase {
	return _prefs.isLowerCase;
}

-(void)setPrefsIsLowerCase:(BOOL)isLowerCase {
	_prefs.isLowerCase = isLowerCase;
	_gameBoard.isLowerCase = _prefs.isLowerCase;
}

-(NezAletterationLetterBlock*)getCurrentLetterBlock {
	return _gameBoard.currentLetterBlock;
}

-(void)setCurrentLetterBlock:(NezAletterationLetterBlock*)currentLetterBlock {
	_gameBoard.currentLetterBlock = currentLetterBlock;
}

-(void)undoTurn {
	NSArray *unretiredList = [_gameBoard.retiredWordBoard removeRetiredWordsForTurnIndex:_gameState.turn];
	if (unretiredList.count > 0) {
		[unretiredList enumerateObjectsUsingBlock:^(NezAletterationRetiredWord *retiredWord, NSUInteger idx, BOOL *stop) {
			NezAletterationWordLine *wordLine = _gameBoard.wordLineList[retiredWord.retiredWord.lineIndex];
			retiredWord.transform = [wordLine nextLetterBlockTransform];
			[wordLine addLetterBlocks:retiredWord.letterBlockList];
		}];
	}
	NezAletterationGameStateTurn *previousStateTurn = _gameState.previousStateTurn;
	NezAletterationWordLine *wordLine = _gameBoard.wordLineList[previousStateTurn.lineIndex];
	NezAletterationLetterBlock *letterBlock = [wordLine removeLastLetterBlock];
	NSLog(@"%@", letterBlock);
	self.currentLetterBlock = letterBlock;
	[_gameState undoTurn];
}

-(void)animateUndoWithFinishedBlock:(NezVoidBlock)undoFinishedBlock {
	__weak NezAletterationGameBoard *gameBoard = self.gameBoard;
	__weak NezAletterationLetterBlock *currentLetterBlock = gameBoard.currentLetterBlock;
	if (currentLetterBlock) {
		__weak NezAletterationLetterStack *letterStack = [gameBoard stackForLetter:currentLetterBlock.letter];
		[letterStack push:currentLetterBlock];
//		[currentLetterBlock animateTransform:letterStack.matrixForTop withDuration:0.25 easingFunction:easeInOutCubic andCompletionHandler:^(BOOL finished) {
//			[myself animateUndoWordsWithFinishedBlock:undoFinishedBlock];
//		}];
	} else {
		[self animateUndoWordsWithFinishedBlock:undoFinishedBlock];
	}
}
	
-(void)animateUndoWordsWithFinishedBlock:(NezVoidBlock)undoFinishedBlock {
	NSArray *unretiredList = [_gameBoard.retiredWordBoard removeRetiredWordsForTurnIndex:_gameState.turn];
	__weak NezAletterationPlayer *myself = self;
	__weak NezAletterationGameBoard *gameBoard = myself.gameBoard;
	NezVoidBlock undoBlock = ^{
		__weak NezAletterationGameStateTurn *previousStateTurn = myself.gameState.previousStateTurn;
		__weak NezAletterationWordLine *wordLine = gameBoard.wordLineList[previousStateTurn.lineIndex];
		myself.currentLetterBlock = [wordLine removeLastLetterBlock];
		[myself.gameState undoTurn];
		if (undoFinishedBlock) {
			undoFinishedBlock();
		}
	};
	if (unretiredList.count > 0) {
		[unretiredList enumerateObjectsUsingBlock:^(NezAletterationRetiredWord *retiredWord, NSUInteger idx, BOOL *stop) {
			__weak NezAletterationWordLine *wordLine = gameBoard.wordLineList[retiredWord.retiredWord.lineIndex];
//			[retiredWord animateTransform:wordLine.nextLetterBlockTransform withDuration:1.0 easingFunction:easeInOutCubic andCompletionHandler:^(BOOL finished) {
//				if (idx == 0) {
//					undoBlock();
//				}
//			}];
			[wordLine addLetterBlocks:retiredWord.letterBlockList];
		}];
	} else {
		undoBlock();
	}
}

-(void)startGame {
	NezAletterationPlayerNotification *notification = [NezAletterationPlayerNotification notificationWithPlayerIndex:self.index];
	[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_START_TURN object:notification userInfo:nil];
}

-(void)startTurn {
	BOOL turnStarted = [self.gameState startTurn];
	if (turnStarted) {
		self.currentLetterBlock = [self.gameBoard popLetterBlockFromStackForLetter:self.gameState.currentLetter];
	} else {
		self.currentLetterBlock = nil;
	}
}

-(void)endTurnWithCompletionHandler:(NezAletteartionEndTurnHandler)completionHandler {
	NSUInteger lineIndex = self.gameState.currentStateTurn.temporaryLineIndex;
	NezAletterationWordLine *wordLine = _gameBoard.wordLineList[lineIndex];
	[wordLine addLetterBlock:self.currentLetterBlock];
	[NezGCD runBackgroundPriorityWithWorkBlock:^{
		[self.gameState endTurn];
	} DoneBlock:^{
		if (completionHandler) {
			NSArray *letterBlockSetupContainerList = [self.gameBoard blockSetupContainerListForGameState:self.gameState];
			completionHandler(letterBlockSetupContainerList);
		}
	}];
}

-(void)turnStarted {
	NSLog(@"doTurn");
}

-(void)blockPlaced {
	NezAletterationPlayerNotification *notification = [NezAletterationPlayerNotification notificationWithPlayerIndex:self.index];
	[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_END_TURN object:notification userInfo:nil];
}

-(void)turnContinues {
	if (self.currentLetterBlock) {
		[self turnStarted];
	} else if (!self.isGameOver) {
		[self retireWord];
	} else {
		[self doGameOver];
	}
}

-(void)retireWord {
	NSLog(@"retireWord");
}

-(void)turnEnded {
	if (self.hasTurnsRemaining) {
		NezAletterationPlayerNotification *notification = [NezAletterationPlayerNotification notificationWithPlayerIndex:self.index];
		[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_START_TURN object:notification userInfo:nil];
	} else {
		self.currentLetterBlock = nil;
		[self turnContinues];
	}
}

-(void)doGameOver {
	[NezGCD dispatchBlock:^{
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:0.5];
		_gameBoard.color = _gameBoard.color;
		[SCNTransaction commit];
		
		NezAletterationPlayerNotification *notification = [NezAletterationPlayerNotification notificationWithPlayerIndex:self.index];
		[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_GAMEOVER object:notification userInfo:nil];
	}];
}

-(BOOL)hasTurnsRemaining {
	return (self.gameState.turn < [NezAletterationGameState letterCount]);
}

-(BOOL)isGameOver {
	if (self.hasTurnsRemaining) {
		return NO;
	}
	for (int i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
		NezAletterationGameStateLineState *lineState = [_gameState currentLineStateForIndex:i];
		if (lineState.state == NEZ_ALETTERATION_INPUT_ISWORD || lineState.state == NEZ_ALETTERATION_INPUT_ISBOTH) {
			return NO;
		}
	}
	return YES;
}

-(void)exitGame:(BOOL)isAnimated andCompletedHandler:(NezVoidBlock)completedHandler {
//	[_gameBoard pushBackAllUsedLetterBlocks:isAnimated andCompletedHandler:completedHandler];
}

@end
