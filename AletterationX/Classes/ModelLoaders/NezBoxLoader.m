//
//  NezBoxLoader.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/16.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezBoxLoader.h"

@implementation NezBoxLoader {
	NezModelVertexArray *_vertexArray;
}

+(instancetype)boxWithWidth:(float)width Height:(float)height Depth:(float)depth SideThickness:(float)sideThickness BottomThickness:(float)thickness {
	return [[self alloc] initWithWidth:width Height:height Depth:depth SideThickness:sideThickness Thickness:thickness IsLid:NO];
}

+(instancetype)lidWithWidth:(float)width Height:(float)height Depth:(float)depth SideThickness:(float)sideThickness TopThickness:(float)thickness {
	return [[self alloc] initWithWidth:width Height:height Depth:depth SideThickness:sideThickness Thickness:thickness IsLid:YES];
}

-(instancetype)initWithWidth:(float)width Height:(float)height Depth:(float)depth SideThickness:(float)sideThickness Thickness:(float)thickness IsLid:(BOOL)isLid {
	if ((self = [super init])) {
		_vertexArray = [NezModelVertexArray vertexArrayWithVertexCount:50 andIndexCount:50];
		
		
	}
	return self;
}

-(GLKVector3)normalForTriangleWithV0:(GLKVector3)v0 V1:(GLKVector3)v1 V2:(GLKVector3)v2 {
	return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(v1, v0), GLKVector3Subtract(v2, v0)));
}

@end
