//
//  NezAletterationDefinition.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/22.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@class NezClickableNode;

@interface NezAletterationDefinition : NezNode

@property (readonly, getter = nextTextNode) SCNNode *nextTextNode;

+(instancetype)definitionWithAttributedStringList:(NSArray*)stringList;
-(instancetype)initWithAttributedStringList:(NSArray*)stringList;

@end
