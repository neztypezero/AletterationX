//
//  NezAletterationWordLine.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationWordLine.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationGameStateLineState.h"

@implementation NezAletterationWordLine {
	NSMutableArray *_letterBlockList;
}

+(instancetype)wordLine {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		_letterBlockList = [NSMutableArray array];
	}
	return self;
}

-(CATransform3D)firstLetterBlockTransform {
	SCNVector3 size = self.dimensions;
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
	return [self convertTransform:CATransform3DMakeTranslation(-size.x/2.0+((letterBlockSize.x)*(0.5)), 0.0, 0.0) toNode:nil];
}

-(CATransform3D)nextLetterBlockTransform {
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
	if (_letterBlockList.count == 0) {
		return self.firstLetterBlockTransform;
	}
	NezAletterationLetterBlock *letterBlock = _letterBlockList.lastObject;
	return CATransform3DTranslate(letterBlock.transform, letterBlockSize.x, 0.0, 0.0);
}

-(void)setColor:(SCNVector3)color {
	[super setColor:color];
	if (self.geometry && self.geometry.firstMaterial) {
		NSColor *c = [NSColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0];
		self.geometry.firstMaterial.diffuse.contents = c;
		self.geometry.firstMaterial.ambient.contents = c;
	}
}

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	if (letterBlock) {
		[_letterBlockList addObject:letterBlock];
	}
}

-(void)addLetterBlocks:(NSArray*)letterBlockList {
	[_letterBlockList addObjectsFromArray:letterBlockList];
}

-(NezAletterationLetterBlock*)removeLastLetterBlock {
	return _letterBlockList.lastObject;
}

-(NSArray*)removeBlocksInRange:(NSRange)range {
	NSArray *blockList = [NSMutableArray array];
	blockList = [_letterBlockList subarrayWithRange:range];
	[_letterBlockList removeObjectsInRange:range];
	return blockList;
}

-(NSArray*)blockSetupContainerListForLineState:(NezAletterationGameStateLineState*)lineState {
	SCNVector3 blockColor = self.color;
	SCNVector3 junkColor = SCNVector3Make(0.85, 0.85, 0.85);
	SCNVector3 blockSize = [NezAletterationGraphics letterBlockSize];
	NSInteger junkStackX = 5;
	
	NSMutableArray *containerList = [NSMutableArray array];
	
	GLKMatrix4 matrix = GLKMatrix4FromCATransform3D(self.firstLetterBlockTransform);

	for (NSInteger idx=0; idx<_letterBlockList.count; idx++) {
		NezAletterationLetterBlock *letterBlock = _letterBlockList[idx];
		SCNVector3 color;
		if (idx < lineState.index) {
			color = junkColor;
		} else {
			if (lineState.state == NEZ_ALETTERATION_INPUT_ISPREFIX || lineState.state == NEZ_ALETTERATION_INPUT_ISWORD || lineState.state == NEZ_ALETTERATION_INPUT_ISBOTH) {
				color = blockColor;
			} else {
				color = junkColor;
			}
		}
		NezAletterationLetterBlockSetupContainer *container;
		NSInteger diff = idx-lineState.index;
		if (diff < 0) {
			float z = 0.0;
			if (diff < -junkStackX) {
				z = (-junkStackX-diff)*blockSize.z;
				diff = -junkStackX;
			}
			GLKTransform transform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4Translate(matrix, diff*blockSize.x, 0.0, z));
			container = [NezAletterationLetterBlockSetupContainer containerWithLetterBlock:letterBlock Position:transform.position Orientation:transform.orientation Color:color];
		} else {
			GLKTransform transform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4Translate(matrix, diff*blockSize.x, 0.0, 0.0));
			container = [NezAletterationLetterBlockSetupContainer containerWithLetterBlock:letterBlock Position:transform.position Orientation:transform.orientation Color:color];
		}
		[containerList addObject:container];
	}
	return [NSArray arrayWithArray:containerList];
}

-(void)reset {
	[_letterBlockList removeAllObjects];
}

@end
