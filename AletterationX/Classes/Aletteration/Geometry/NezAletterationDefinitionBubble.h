//
//  NezAletterationDefinitionBubble.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/25.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@class NezAletterationRetiredWord;

@interface NezAletterationDefinitionBubble : NezNode

@property (readonly, getter = isShowing) BOOL isShowing;

+(instancetype)bubble;

-(void)setDefinitionWithRetiredWord:(NezAletterationRetiredWord*)retiredWord;

-(void)reset;

@end
