//
//  NezSurfaceColorMaterial.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezSurfaceColorMaterial.h"

@implementation NezSurfaceColorMaterial

+(instancetype)materialWithShaderPath:(NSString*)path {
	NezSurfaceColorMaterial *material = [self material];
	if (material) {
		NSString *shaderSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		material.shaderModifiers = @{ SCNShaderModifierEntryPointSurface : shaderSource };
	}
	return material;
}

@end
