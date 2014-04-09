//
//  NezClickableNode.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"
#import "NezClickable.h"

@interface NezClickableNode : NezNode<NezClickable>

+(instancetype)nodeWithGeometry:(SCNGeometry*)geometry;

@end
