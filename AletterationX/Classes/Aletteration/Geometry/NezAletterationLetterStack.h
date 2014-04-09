//
//  NezAletterationLetterStack.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@class NezAletterationLetterBlock;

@interface NezAletterationLetterStack : NezNode

@property (readonly, getter = matrixForTop) CATransform3D matrixForTop;
@property (readonly, getter = count) NSInteger count;
@property (readonly, getter = letterBlockList) NSArray *letterBlockList;
@property (readonly, getter = letterBlockPlacementNode) SCNNode *letterBlockPlacementNode;

+(instancetype)stack;

-(void)push:(NezAletterationLetterBlock*)letterBlock;
-(NezAletterationLetterBlock*)pop;

-(void)sort;
-(void)reset;

@end
