//
//  NezAletterationRetiredWordBoard.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@class NezAletterationRetiredWord;
@class NezAletterationDefinitionBubble;

@interface NezAletterationRetiredWordBoard : NezNode

@property (readonly) NezAletterationDefinitionBubble *definitionBubble;

+(instancetype)board;

-(NSArray*)removeRetiredWordsForTurnIndex:(NSInteger)turnIndex;

-(CATransform3D)transformForNextWord;

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord;

-(void)reset;

@end
