//
//  NezAletterationGameState.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationSQLiteDictionary.h"

typedef enum NezAletterationInputType {
	NEZ_ALETTERATION_INPUT_ISNOT_SET = -1,
	NEZ_ALETTERATION_INPUT_ISNOTHING,
	NEZ_ALETTERATION_INPUT_ISPREFIX,
	NEZ_ALETTERATION_INPUT_ISWORD,
	NEZ_ALETTERATION_INPUT_ISBOTH,
	NEZ_ALETTERATION_INPUT_IS_NO_MORE,
} NezAletterationInputType;

#define NEZ_ALETTERATION_ALPHABET_COUNT 26
#define NEZ_ALETTERATION_LINE_COUNT 6

typedef struct NezAletterationLetterBag {
	int count[NEZ_ALETTERATION_ALPHABET_COUNT];
} NezAletterationLetterBag;

@class NezAletterationGameStateTurn;
@class NezAletterationGameStateLineState;
@class NezAletterationGameStateRetiredWord;

@interface NezAletterationGameState : NSObject<NSCoding>

@property (readonly, getter = getLetterList) char *letterList;
@property (readonly, getter = getCurrentLetter) char currentLetter;
@property (readonly, getter = getCurrentLetterIndex) char currentLetterIndex;
@property (readonly, getter = getTurn) int64_t turn;
@property (readonly, getter = getPreviousTurn) int64_t previousTurn;
@property (readonly, getter = getCurrentStateTurn) NezAletterationGameStateTurn *currentStateTurn;
@property (readonly, getter = getPreviousStateTurn) NezAletterationGameStateTurn *previousStateTurn;
@property (readonly, getter = getCurrentLetterBagPtr) NezAletterationLetterBag *currentLetterBagPtr;
@property (readonly, getter = getCurrentLetterBagCopy) NezAletterationLetterBag currentLetterBagCopy;

+(instancetype)gameState;
+(instancetype)gameStateWithLetterList:(char*)letterList;

+(int)letterCount;
+(NezAletterationLetterBag)fullLetterBag;
+(void)randomizedLetterList:(char*)letterList;

-(instancetype)initWithLetterList:(char*)letterList;

-(BOOL)startTurn;
-(void)placeCurrentLetterOnLine:(NSUInteger)lineIndex;
-(void)endTurn;
-(void)endTurnWithLineIndex:(int64_t)lineIndex andUpdatedLineStateList:(NSArray*)updatedLineStateList;
-(void)undoTurn;

-(int64_t)getLineLengthForLineIndex:(NSUInteger)lineIndex;
-(void)copyFromLine:(NSUInteger)lineIndex intoLine:(char*)word;

-(NezAletterationGameStateLineState*)currentLineStateForIndex:(int64_t)index;

-(NezAletterationGameStateRetiredWord*)retireWordFromLine:(int64_t)lineIndex;

-(char)letterForTurn:(int64_t)turnIndex;
-(NSArray*)turnsInRange:(NSRange)range;

-(void)useLetterList:(char*)srcLetterList;
-(void)copyLetterListIntoArray:(char*)dstLetterList;

-(NezAletterationInputType)inputTypeForLine:(char*)line andLineState:(NezAletterationGameStateLineState*)lineState;
-(NezAletterationInputType)inputTypeForLine:(char*)line andLetterCounts:(NezAletterationLetterBag)letterCounts;
-(NezAletterationInputType)inputTypeForCounts:(NezAletterationDictionaryCounts)counts;

-(NezAletterationDictionaryCounts)countsForLine:(char*)line andLetterCounts:(NezAletterationLetterBag)letterCounts;

@end
