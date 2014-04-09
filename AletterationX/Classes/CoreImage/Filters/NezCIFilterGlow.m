//
//  NezCIFilterGlow.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/12.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezCIFilterGlow.h"

@implementation NezCIFilterGlow

@synthesize inputRadius;
@synthesize color;

-(NSArray *)attributeKeys {
	return @[@"inputRadius", @"color"];
}

-(CIImage *)outputImage {
	CIImage *inputImage = [self valueForKey:@"inputImage"];
	if (!inputImage)
		return nil;
	
	// Monochrome
	CIFilter *monochromeFilter = [CIFilter filterWithName:@"CIColorMatrix"];
	[monochromeFilter setDefaults];
	[monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:[color redComponent]] forKey:@"inputRVector"];
	[monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:[color greenComponent]] forKey:@"inputGVector"];
	[monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:[color blueComponent]] forKey:@"inputBVector"];
	[monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:[color alphaComponent]] forKey:@"inputAVector"];
	[monochromeFilter setValue:inputImage forKey:@"inputImage"];
	CIImage *glowImage = [monochromeFilter valueForKey:@"outputImage"];
	
//	// Scale
//	float centerX = [self.centerX floatValue];
//	float centerY = [self.centerY floatValue];
//	if (centerX > 0) {
//		NSAffineTransform *transform = [NSAffineTransform transform];
//		[transform translateXBy:centerX yBy:centerY];
//		[transform scaleBy:1.1];
//		[transform translateXBy:-centerX yBy:-centerY];
//		
//		CIFilter *affineTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
//		[affineTransformFilter setDefaults];
//		[affineTransformFilter setValue:transform forKey:@"inputTransform"];
//		[affineTransformFilter setValue:glowImage forKey:@"inputImage"];
//		glowImage = [affineTransformFilter valueForKey:@"outputImage"];
//	}
	
	// Blur
	CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[gaussianBlurFilter setDefaults];
	[gaussianBlurFilter setValue:glowImage forKey:@"inputImage"];
	[gaussianBlurFilter setValue:self.inputRadius ?: @10.0 forKey:@"inputRadius"];
	glowImage = [gaussianBlurFilter valueForKey:@"outputImage"];
	
	// Blend
	CIFilter *blendFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
	[blendFilter setDefaults];
	[blendFilter setValue:glowImage forKey:@"inputBackgroundImage"];
	[blendFilter setValue:inputImage forKey:@"inputImage"];
	glowImage = [blendFilter valueForKey:@"outputImage"];
	
	return glowImage;
}


@end
