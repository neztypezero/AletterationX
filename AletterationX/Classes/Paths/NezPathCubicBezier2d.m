//
//  NezPathCubicBezier2d.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezPathCubicBezier2d.h"

@implementation NezPathCubicBezier2d

+(instancetype)bezier {
	GLKVector2 zero = GLKVector2Make(0, 0);
	return [[self alloc] initWithControlPointsP0:zero P1:zero P2:zero P3:zero];
}

+(instancetype)bezierWithControlPointsP0:(GLKVector2)p0 P1:(GLKVector2)p1 P2:(GLKVector2)p2 P3:(GLKVector2)p3 {
	return [[self alloc] initWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
}

+(instancetype)bezierWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector2)p3 {
	return [[self alloc] initWithControlPointsP0:p0 P1Z:p1Z P2Z:p2Z P3:p3];
}

+(instancetype)bezierWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector2)p3 {
	return [[self alloc] initWithControlPointsP0:p0 P1Z:p1Z P1T:p1T P2Z:p2Z P2T:p2T P3:p3];
}

-(instancetype)initWithControlPointsP0:(GLKVector2)p0 P1:(GLKVector2)p1 P2:(GLKVector2)p2 P3:(GLKVector2)p3 {
	if ((self = [super init])) {
		[self setControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
	}
	return self;
}

-(instancetype)initWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector2)p3 {
	if ((self = [super init])) {
		[self setControlPointsP0:p0 P1Z:p1Z P2Z:p2Z P3:p3];
	}
	return self;
}

-(instancetype)initWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector2)p3 {
	if ((self = [super init])) {
		[self setControlPointsP0:p0 P1Z:p1Z P1T:p1T P2Z:p2Z P2T:p2T P3:p3];
	}
	return self;
}

-(void)setControlPointsP0:(GLKVector2)p0 P1:(GLKVector2)p1 P2:(GLKVector2)p2 P3:(GLKVector2)p3 {
	_p0 = p0;
	_p1 = p1;
	_p2 = p2;
	_p3 = p3;
}

-(void)setControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector2)p3 {
	[self setControlPointsP0:p0 P1Z:p1Z P1T:0.25 P2Z:p2Z P2T:0.75 P3:p3];
}

-(void)setControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector2)p3 {
	_p0 = p0;
	_p1 = GLKVector2Lerp(p0, p3, p1T);
	_p2 = GLKVector2Lerp(p0, p3, p2T);
	_p3 = p3;
}

/*
 De Casteljau Algorithm
 http://en.wikipedia.org/wiki/De_Casteljau's_algorithm (Geometric interpretation)
 */
-(GLKVector2)positionAt:(float)t {
	GLKVector2 P01 = GLKVector2Lerp(_p0, _p1, t);
	GLKVector2 P12 = GLKVector2Lerp(_p1, _p2, t);
	GLKVector2 P23 = GLKVector2Lerp(_p2, _p3, t);
	GLKVector2 P0112 = GLKVector2Lerp(P01, P12, t);
	GLKVector2 P1223 = GLKVector2Lerp(P12, P23, t);
	return GLKVector2Lerp(P0112, P1223, t);
}

@end
