//
//  NezAletterationDefinition.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/22.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationDefinition.h"
#import "NezAletterationGraphics.h"
#import "NezClickableNode.h"

static const float kInnerBigWidth = 300.0;
static const float kInnerBigHeight = 300.0;

@implementation NezAletterationDefinition {
	NSUInteger _index;
	NSArray *_definitionList;
	NSMutableArray *_textNodeList;
}

+(instancetype)definitionWithAttributedStringList:(NSArray*)stringList {
	return [[self alloc] initWithAttributedStringList:stringList];
}

-(instancetype)initWithAttributedStringList:(NSArray*)stringList {
	if ((self = [super init])) {
		_definitionList = [NSArray arrayWithArray:stringList];
		_index = _definitionList.count;
		_textNodeList = [NSMutableArray arrayWithCapacity:_definitionList.count];
		for (NSUInteger i=0; i<_definitionList.count; i++) {
			SCNNode *textNode = [SCNNode node];
			[_textNodeList addObject:textNode];
		}
	}
	return self;
}

-(SCNNode*)nextTextNode {
	_index++;
	if (_index >= _textNodeList.count) {
		_index = 0;
	}
	SCNNode *textNode = _textNodeList[_index];
	if (!textNode.geometry) {
		NSAttributedString *attributedString = [self definitionStringForIndex:_index];
		SCNText *text = [SCNText textWithString:attributedString extrusionDepth:1.50];
		text.flatness = 0.025;
		text.chamferRadius = 0.0;
		text.wrapped = YES;
		text.truncationMode = kCATruncationNone;
		text.containerFrame = CGRectMake(0.0, -kInnerBigHeight, kInnerBigWidth, kInnerBigHeight);
		textNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_TEXT;
		textNode.geometry = text;
	}
	return textNode;
}

-(NSAttributedString*)definitionStringForIndex:(NSUInteger)index {
	return _definitionList[index];
}

@end
