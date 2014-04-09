//
//  NezAletterationRetiredWordBoard.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationRetiredWordBoard.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationDefinition.h"
#import "NezAletterationDefinitionBubble.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationGraphics.h"

@implementation NezAletterationRetiredWordBoard {
	NSMutableArray *_retiredWordList;
	SCNVector3 _size;
	
	NezAletterationRetiredWord *_shownDefinitionWord;
}

+(instancetype)board {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		_retiredWordList = [NSMutableArray array];
		SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
		_size = SCNVector3Make(letterBlockSize.x*12.0, letterBlockSize.y*12.0, 0.0);
		self.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_RETIRED_WORDBOARD;
		
		_definitionBubble = [NezAletterationDefinitionBubble bubble];
		[self addChildNode:_definitionBubble];
	}
	return self;
}

-(SCNVector3)dimensions {
	return _size;
}

-(CATransform3D)transformForNextWord {
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
	SCNVector3 t = SCNVector3Make(-_size.x*0.5+letterBlockSize.x*0.5, _size.y*0.5-letterBlockSize.y*0.5-([NezAletterationGameBoard lineSpaceMultiplier]*letterBlockSize.y)*((float)_retiredWordList.count), 0.0);
	return [self convertTransform:CATransform3DMakeTranslation(t.x, t.y, t.z) toNode:nil];
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	__weak NezAletterationRetiredWord *weakRetiredWord = retiredWord;
	retiredWord.mouseUp = ^(SCNView *view, NSEvent *event) {
		[self showDefinitionForWord:weakRetiredWord];
	};
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
	CATransform3D t = CATransform3DTranslate([self transformForNextWord], ((retiredWord.length-1)*0.5)*letterBlockSize.x, 0.0, 0.0);
	retiredWord.transform = [self convertTransform:t fromNode:nil];
	[self addChildNode:retiredWord];
	[_retiredWordList addObject:retiredWord];
}

-(NSArray*)removeRetiredWordsForTurnIndex:(NSInteger)turnIndex {
	return nil;
}

-(void)showDefinitionForWord:(NezAletterationRetiredWord*)word {
	[_definitionBubble setDefinitionWithRetiredWord:word];
}

-(void)reset {
	[_definitionBubble reset];
	for (NezAletterationRetiredWord *retiredWord in _retiredWordList) {
		[retiredWord reset];
	}
	[_retiredWordList removeAllObjects];
}

@end
