//
//  NezAletterationWordLine.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@class NezAletterationLetterBlock;
@class NezAletterationGameStateLineState;

@interface NezAletterationWordLine : NezNode

@property (readonly, getter = firstLetterBlockTransform) CATransform3D firstLetterBlockTransform;
@property (readonly, getter = nextLetterBlockTransform) CATransform3D nextLetterBlockTransform;
@property NSUInteger index;

+(instancetype)wordLine;

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(void)addLetterBlocks:(NSArray*)letterBlockList;

-(NezAletterationLetterBlock*)removeLastLetterBlock;

-(NSArray*)removeBlocksInRange:(NSRange)range;

-(NSArray*)blockSetupContainerListForLineState:(NezAletterationGameStateLineState*)lineState;

-(void)reset;

@end
