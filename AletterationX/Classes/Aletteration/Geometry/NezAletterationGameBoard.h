//
//  NezAletterationGameBoard.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"
#import "NezAletterationGameState.h"

@class NezAletterationLetterBlock;
@class NezAletterationRetiredWordBoard;
@class NezAletterationGameState;
@class NezAletterationLetterStack;
@class NezAletterationBox;
@class NezAletterationWordLine;

@interface NezAletterationGameBoard : NezNode

@property (readonly, getter = letterBlockList) NSArray *letterBlockList;
@property (readonly, getter = wordLineList) NSArray *wordLineList;
@property (readonly, getter = stackList) NSArray *stackList;
@property (readonly, getter = defaultLetterBlockTransform) CATransform3D defaultLetterBlockTransform;
@property (strong) NezAletterationBox *box;
@property (strong) NezAletterationBox *lid;

@property (setter = setCurrentLetterBlock:, getter = currentLetterBlock) NezAletterationLetterBlock *currentLetterBlock;
@property (setter = setIsLowerCase:, getter = isLowerCase) BOOL isLowerCase;
@property (setter = setRetiredWordBoard:, getter = retiredWordBoard) NezAletterationRetiredWordBoard *retiredWordBoard;

+(instancetype)board;

+(float)lineSpaceMultiplier;

-(void)setupLetterBlocksForGameState:(NezAletterationGameState*)gameState isAnimated:(BOOL)isAnimated;

-(NezAletterationLetterStack*)stackForLetter:(char)letter;

-(BOOL)allStacksHaveCount:(NezAletterationLetterBag)letterBag;

-(NezAletterationLetterBlock*)popLetterBlockFromStackForLetter:(char)letter;

-(NezAletterationWordLine*)wordLineForIndex:(NSUInteger)index;

-(NSArray*)blockSetupContainerListForGameState:(NezAletterationGameState*)gameState;

-(void)resetAllLetterBlockContainers;

@end
