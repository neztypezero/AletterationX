//
//  NezAletterationBigBox.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/06.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationBigBox.h"

@implementation NezAletterationBigBox

-(CATransform3D)transformForSmallBox:(NezAletterationBox*)smallBox andPlayerIndex:(NSInteger)playerIndex {
	GLKVector2 positions[4] = {
		{ 1, -1},
		{-1, -1},
		{-1,  1},
		{ 1,  1},
	};
	float spaceInBetweenRatio = 0.08;
	SCNVector3 boxSize = smallBox.dimensions;
	float letterBoxZ = self.insideThickness-((self.dimensions.z*0.5)-(boxSize.z*0.5));
	
	CATransform3D transform = CATransform3DTranslate(self.transform, -boxSize.y*(0.5+spaceInBetweenRatio)*positions[playerIndex].x, (boxSize.x/2.0+boxSize.y*(spaceInBetweenRatio*1.5))*positions[playerIndex].y, letterBoxZ);
	transform = CATransform3DRotate(transform, M_PI/2.0, 0.0, 0.0, 1.0);
	
	return transform;
}

-(GLKTransform)glkTransformForSmallBox:(NezAletterationBox*)smallBox andPlayerIndex:(NSInteger)playerIndex {
	GLKVector2 positions[4] = {
		{ 1, -1},
		{-1, -1},
		{-1,  1},
		{ 1,  1},
	};
	float spaceInBetweenRatio = 0.08;
	SCNVector3 boxSize = smallBox.dimensions;
	float letterBoxZ = self.insideThickness-((self.dimensions.z*0.5)-(boxSize.z*0.5));
	
	CATransform3D transform = CATransform3DTranslate(self.transform, -boxSize.y*(0.5+spaceInBetweenRatio)*positions[playerIndex].x, (boxSize.x/2.0+boxSize.y*(spaceInBetweenRatio*1.5))*positions[playerIndex].y, letterBoxZ);
	transform = CATransform3DRotate(transform, M_PI/2.0, 0.0, 0.0, 1.0);
	
	return GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(transform));
}

@end
