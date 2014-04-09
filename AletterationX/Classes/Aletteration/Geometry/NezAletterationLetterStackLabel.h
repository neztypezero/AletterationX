//
//  NezAletterationStackLabel.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"
#import "NezInstanceAttributeTypes.h"

@class NezInstanceVertexArrayObjectColorTexture;

@interface NezAletterationLetterStackLabel : NezAletterationRestorableGeometry

@property (nonatomic, setter = setCount:) NSInteger count;
@property (getter = getColor, setter = setColor:) GLKVector4 color;

-(instancetype)initWithLabelVao:(NezInstanceVertexArrayObjectColorTexture*)labelVao labelAttributeIndex:(NSInteger)labelAttributeIndex;

-(void)animateColor:(GLKVector4)color;

@end
