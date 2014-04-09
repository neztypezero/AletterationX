//
//  NezAletterationLetterStack.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterStack.h"
#import "NezAletterationGraphics.h"

@implementation NezAletterationLetterStack {
	NezNode *_letterBlockPlacementNode;
	NezNode *_stackCounterNode;
	NSMutableArray *_letterBlockList;
}

+(instancetype)stack {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		_letterBlockList = [NSMutableArray array];
		
		SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
		
		_letterBlockPlacementNode = [NezNode node];
		[self addChildNode:_letterBlockPlacementNode];
		
		_stackCounterNode = [NezNode nodeWithGeometry:[SCNPlane planeWithWidth:letterBlockSize.x*0.5 height:letterBlockSize.y*0.5]];
		_stackCounterNode.geometry.firstMaterial = [NezAletterationGraphics textureMaterial:[NezAletterationGraphics resourceTexturePathWithFilename:@"00" Type:@"png" Dir:@"Numbers"]];
		_stackCounterNode.geometry.firstMaterial.writesToDepthBuffer = NO;
		_stackCounterNode.geometry.firstMaterial.readsFromDepthBuffer = NO;
		_stackCounterNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_STACK_LABEL;
		_stackCounterNode.transform = CATransform3DMakeTranslation(0.0, -letterBlockSize.y, 0.0);
		[self addChildNode:_stackCounterNode];
		
		[self setCountLabel];
	}
	return self;
}

-(SCNNode*)letterBlockPlacementNode {
	return _letterBlockPlacementNode;
}

-(NSInteger)count {
	return _letterBlockList.count;
}

-(NSArray*)letterBlockList {
	return _letterBlockList;
}

-(void)setCountLabel {
	CATransform3D uvTransform = [self textureCoordTransformForCount:_letterBlockList.count];
	_stackCounterNode.geometry.firstMaterial.diffuse.contentsTransform = uvTransform;
	_stackCounterNode.geometry.firstMaterial.ambient.contentsTransform = uvTransform;
}

-(CATransform3D)textureCoordTransformForCount:(NSInteger)count {
	NSInteger x = count%8;
	NSInteger y = count/8;
	
	return CATransform3DTranslate(CATransform3DMakeScale(0.125, 0.125, 1.0), x, y, 0.0);
}

-(CATransform3D)matrixForTop {
	return [self matrixForCount:_letterBlockList.count];
}

-(CATransform3D)matrixForCount:(NSInteger)count {
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
	
	CATransform3D transform = [_letterBlockPlacementNode convertTransform:CATransform3DIdentity toNode:nil];
	transform = CATransform3DTranslate(transform, 0.0, 0.0, letterBlockSize.z*(count+0.5));
	return transform;
}

-(void)sort {
	[_letterBlockList sortUsingComparator:^NSComparisonResult(NezAletterationLetterBlock* lb1, NezAletterationLetterBlock* lb2) {
		if (lb1.stackIndex > lb2.stackIndex) {
			return NSOrderedDescending;
		} else if (lb1.stackIndex < lb2.stackIndex) {
			return NSOrderedAscending;
		}
		return NSOrderedSame;
	}];
}

-(void)push:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockList addObject:letterBlock];
	[self setCountLabel];
}

-(NezAletterationLetterBlock*)pop {
	NezAletterationLetterBlock *topLetterBlock = _letterBlockList.lastObject;
	[_letterBlockList removeLastObject];
	[self setCountLabel];
	return topLetterBlock;
}

-(void)reset {
	[_letterBlockList removeAllObjects];
	[self setCountLabel];
}

@end
