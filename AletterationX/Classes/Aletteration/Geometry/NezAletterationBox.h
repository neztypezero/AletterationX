//
//  NezAletterationBox.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezDynamicNode.h"

@class NezAletterationLetterBlock;

@interface NezAletterationBox : NezDynamicNode

@property float sideThickness;
@property float insideThickness;
@property BOOL isLid;

+(instancetype)box;
+(instancetype)lid;

-(CATransform3D)transformForLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(CATransform3D)relativeTransformForLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(CATransform3D)transformForLid:(NezAletterationBox*)lid;
-(CATransform3D)transformForLid:(NezAletterationBox*)lid withBoxTransform:(CATransform3D)transform;
-(GLKTransform)glkTransformForLid:(NezAletterationBox*)lid withBoxGLKTransform:(GLKTransform)transform;

@end
