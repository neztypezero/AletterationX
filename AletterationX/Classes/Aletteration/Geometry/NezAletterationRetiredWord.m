//
//  NezAletterationRetiredWord.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationRetiredWord.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationDefinition.h"

@implementation NezAletterationRetiredWord {
	NezAletterationDefinition *_definition;
}

+(instancetype)retiredWordWithGameStateRetiredWord:(NezAletterationGameStateRetiredWord*)retiredWord turnIndex:(NSInteger)turnIndex andLetterBlockList:(NSArray*)letterBlockList {
	return [[self alloc] initWithGameStateRetiredWord:retiredWord turnIndex:turnIndex andLetterBlockList:letterBlockList];
}

-(instancetype)initWithGameStateRetiredWord:(NezAletterationGameStateRetiredWord*)retiredWord turnIndex:(NSInteger)turnIndex andLetterBlockList:(NSArray*)letterBlockList {
	if ((self = [super init])) {
		_retiredWord = retiredWord;
		_letterBlockList = letterBlockList;
		_turnIndex = turnIndex;
		
		SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
		self.geometry = [SCNPlane planeWithWidth:letterBlockSize.x*letterBlockList.count height:letterBlockSize.y];
		self.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_NONE;
	}
	return self;
}

-(NSUInteger)length {
	return _letterBlockList.count;
}

-(NSInteger)getBonusLetterCount {
	return 0;
}

-(NSString*)word {
	char word[128];
	int i=0;
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		word[i++] = letterBlock.letter;
	}
	word[i] = '\0';
	NSString *s = [NSString stringWithFormat:@"%s", word];
	return s;
}

-(void)reset {
	self.definition = nil;
	self.mouseDown = nil;
	self.mouseUp = nil;
}

@end
