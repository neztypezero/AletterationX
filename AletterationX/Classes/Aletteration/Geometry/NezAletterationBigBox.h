//
//  NezAletterationBigBox.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/06.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationBox.h"

@interface NezAletterationBigBox : NezAletterationBox

-(CATransform3D)transformForSmallBox:(NezAletterationBox*)smallBox andPlayerIndex:(NSInteger)playerIndex;
-(GLKTransform)glkTransformForSmallBox:(NezAletterationBox*)smallBox andPlayerIndex:(NSInteger)playerIndex;

@end
