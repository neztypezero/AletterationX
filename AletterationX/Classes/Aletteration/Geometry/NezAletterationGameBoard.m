//
//  NezAletterationGameBoard.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationGeometry.h"
#import "NezAletterationGraphics.h"

static const float kLineSpaceMultiplier = 1.1;

@implementation NezAletterationGameBoard {
	NezAletterationLetterBlock *_currentLetterBlock;
	NezAletterationRetiredWordBoard *_retiredWordBoard;
	BOOL _isLowerCase;
	NSArray *_stackList;
	NSArray *_wordLineList;
	NSArray *_letterBlockList;
}

+(float)lineSpaceMultiplier {
	return kLineSpaceMultiplier;
}

+(instancetype)board {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		self.box = [NezAletterationGraphics newSmallBox];
		self.lid = [NezAletterationGraphics newSmallLid];

		_letterBlockList = [NezAletterationGraphics newLetterBlockList];
		
		SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
		
		NSMutableArray *wordLineList = [NSMutableArray arrayWithCapacity:NEZ_ALETTERATION_LINE_COUNT];
		for (NSUInteger j=0;j<NEZ_ALETTERATION_LINE_COUNT;j++) {
			NezAletterationWordLine *wordLine = [NezAletterationGraphics newWordLine];
			wordLine.transform = CATransform3DMakeTranslation(0.0, letterBlockSize.y*kLineSpaceMultiplier*j, 0.0);
			wordLine.opacity = 0.25;
			wordLine.index = j;
			
			[self addChildNode:wordLine];
			[wordLineList addObject:wordLine];
		}
		_wordLineList = [NSArray arrayWithArray:wordLineList];

		SCNVector3 wordLineSize = [NezAletterationGraphics wordLineSize];
		
		_retiredWordBoard = [NezAletterationRetiredWordBoard board];
		SCNVector3 retiredBoardSize = _retiredWordBoard.dimensions;
		_retiredWordBoard.transform = CATransform3DMakeTranslation(wordLineSize.x*0.5+retiredBoardSize.x*0.5+letterBlockSize.x*0.5, letterBlockSize.y*0.5+letterBlockSize.y*kLineSpaceMultiplier*(NEZ_ALETTERATION_LINE_COUNT-1)-retiredBoardSize.y*0.5, 0.0);
		[self addChildNode:_retiredWordBoard];

		CATransform3D transform = CATransform3DMakeTranslation((-letterBlockSize.x*1.5)*(NEZ_ALETTERATION_ALPHABET_COUNT/4.0)+letterBlockSize.x*0.75, -letterBlockSize.y*2.0, 0.0);
		
		NSMutableArray *stackList = [NSMutableArray arrayWithCapacity:NEZ_ALETTERATION_ALPHABET_COUNT];
		for (int i=0; i<NEZ_ALETTERATION_ALPHABET_COUNT; i++) {
			NezAletterationLetterStack *stack = [NezAletterationLetterStack stack];
			stack.transform = transform;
			if (i == (NEZ_ALETTERATION_ALPHABET_COUNT/2)-1) {
				transform = CATransform3DMakeTranslation((-letterBlockSize.x*1.5)*(NEZ_ALETTERATION_ALPHABET_COUNT/4.0)+letterBlockSize.x*0.75, -letterBlockSize.y*4.5, 0.0);
			} else {
				transform = CATransform3DTranslate(transform, letterBlockSize.x*1.5, 0.0, 0.0);
			}
			[stackList addObject:stack];
			[self addChildNode:stack];
		}
		_stackList = [NSArray arrayWithArray:stackList];
	}
	return self;
}

-(NSArray*)letterBlockList {
	return _letterBlockList;
}

-(void)setColor:(SCNVector3)color {
	[super setColor:color];
	self.box.color = color;
	self.lid.color = color;
	for (NezAletterationWordLine *wordLine in _wordLineList) {
		wordLine.color = color;
	}
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		letterBlock.color = color;
	}
}

-(NSArray*)wordLineList {
	return _wordLineList;
}

-(BOOL)allStacksHaveCount:(NezAletterationLetterBag)letterBag {
	__block BOOL returnValue = YES;
	[_stackList enumerateObjectsUsingBlock:^(NezAletterationLetterStack *stack, NSUInteger idx, BOOL *stop) {
		if (stack.count != letterBag.count[idx]) {
			returnValue = NO;
			*stop = YES;
		}
	}];
	return returnValue;
}

-(NezAletterationLetterBlock*)currentLetterBlock {
	return _currentLetterBlock;
}

-(void)setCurrentLetterBlock:(NezAletterationLetterBlock*)currentLetterBlock {
	_currentLetterBlock = currentLetterBlock;
}

-(NezAletterationRetiredWordBoard*)retiredWordBoard {
	return _retiredWordBoard;
}

-(void)setRetiredWordBoard:(NezAletterationRetiredWordBoard*)retiredWordBoard {
	_retiredWordBoard = retiredWordBoard;
}

-(BOOL)isLowerCase {
	return _isLowerCase;
}

-(void)setIsLowerCase:(BOOL)isLowerCase {
	_isLowerCase = isLowerCase;
}

-(NezAletterationLetterBlock*)popLetterBlockFromStackForLetter:(char)letter {
	NezAletterationLetterStack *letterStack = [self stackForLetter:letter];
	NezAletterationLetterBlock *letterBlock = [letterStack pop];
	return letterBlock;
}

-(CATransform3D)defaultLetterBlockTransform {
	SCNVector3 size = [NezAletterationGraphics letterBlockSize];
	return CATransform3DTranslate(self.transform, 0.0, -size.y*1.95, size.z*50.0);
}

-(void)setupLetterBlocksForGameState:(NezAletterationGameState*)gameState isAnimated:(BOOL)isAnimated {
	
}

-(NezAletterationWordLine*)wordLineForIndex:(NSUInteger)index {
	return _wordLineList[index];
}

-(NSArray*)stackList {
	return _stackList;
}

-(NezAletterationLetterStack*)stackForLetter:(char)letter {
	return _stackList[letter-'a'];
}

-(NSArray*)blockSetupContainerListForGameState:(NezAletterationGameState*)gameState {
	NSMutableArray *containerList = [NSMutableArray array];
	for (NezAletterationWordLine *wordLine in _wordLineList) {
		[containerList addObjectsFromArray:[wordLine blockSetupContainerListForLineState:[gameState currentLineStateForIndex:wordLine.index]]];
	}
	return [NSArray arrayWithArray:containerList];
}

-(void)resetAllLetterBlockContainers {
	for (NezAletterationWordLine *wordLine in _wordLineList) {
		[wordLine reset];
	}
	for (NezAletterationLetterStack *stack in _stackList) {
		[stack reset];
	}
	[_retiredWordBoard reset];
}

@end
