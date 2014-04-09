//
//  NezAletterationRetiredWord.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezClickableNode.h"

@class NezAletterationGameStateRetiredWord;
@class NezAletterationDefinition;

@interface NezAletterationRetiredWord : NezClickableNode

@property (nonatomic, readonly) NSArray *letterBlockList;
@property (nonatomic, readonly) NezAletterationGameStateRetiredWord *retiredWord;
@property (readonly) NSInteger turnIndex;
@property (readonly, getter = getBonusLetterCount) NSInteger bonusLetterCount;
@property (readonly, getter = word) NSString *word;
@property (readonly, getter = length) NSUInteger length;
@property (nonatomic, strong) NezAletterationDefinition *definition;

+(instancetype)retiredWordWithGameStateRetiredWord:(NezAletterationGameStateRetiredWord*)retiredWord turnIndex:(NSInteger)turnIndex andLetterBlockList:(NSArray*)letterBlockList;
-(instancetype)initWithGameStateRetiredWord:(NezAletterationGameStateRetiredWord*)retiredWord turnIndex:(NSInteger)turnIndex andLetterBlockList:(NSArray*)letterBlockList;

-(void)reset;

@end
