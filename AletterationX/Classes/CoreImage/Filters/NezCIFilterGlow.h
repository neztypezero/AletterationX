//
//  NezCIFilterGlow.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/12.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NezCIFilterGlow : CIFilter

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;
@property (retain, nonatomic) NSNumber *centerX;
@property (retain, nonatomic) NSNumber *centerY;
@property (retain, nonatomic) NSColor *color;

@end
