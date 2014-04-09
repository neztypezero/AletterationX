//
//  NezCubicBezier.m
//  Aletteration
//
//  Created by David Nesbitt on 2/25/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezPathCubicBezier3d.h"

@implementation NezPathCubicBezier3d

+(instancetype)bezier {
	GLKVector3 zero = GLKVector3Make(0, 0, 0);
	return [[self alloc] initWithControlPointsP0:zero P1:zero P2:zero P3:zero];
}

+(instancetype)bezierWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3 {
	return [[self alloc] initWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
}

+(instancetype)bezierWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector3)p3 {
	return [[self alloc] initWithControlPointsP0:p0 P1Z:p1Z P2Z:p2Z P3:p3];
}

+(instancetype)bezierWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector3)p3 {
	return [[self alloc] initWithControlPointsP0:p0 P1Z:p1Z P1T:p1T P2Z:p2Z P2T:p2T P3:p3];
}

-(instancetype)initWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3 {
	if ((self = [super init])) {
		[self setControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
	}
	return self;
}

-(instancetype)initWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector3)p3 {
	if ((self = [super init])) {
		[self setControlPointsP0:p0 P1Z:p1Z P2Z:p2Z P3:p3];
	}
	return self;
}

-(instancetype)initWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector3)p3 {
	if ((self = [super init])) {
		[self setControlPointsP0:p0 P1Z:p1Z P1T:p1T P2Z:p2Z P2T:p2T P3:p3];
	}
	return self;
}

-(void)setControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3 {
	_p0 = p0;
	_p1 = p1;
	_p2 = p2;
	_p3 = p3;
}

-(void)setControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector3)p3 {
	[self setControlPointsP0:p0 P1Z:p1Z P1T:0.25 P2Z:p2Z P2T:0.75 P3:p3];
}

-(void)setControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector3)p3 {
	_p0 = p0;
	_p1 = GLKVector3Lerp(p0, p3, p1T);
	_p1.z = p1Z;
	_p2 = GLKVector3Lerp(p0, p3, p2T);
	_p2.z = p2Z;
	_p3 = p3;
}

/*
 De Casteljau Algorithm
 http://en.wikipedia.org/wiki/De_Casteljau's_algorithm (Geometric interpretation)
 */
-(GLKVector3)positionAt:(float)t {
	GLKVector3 P01 = GLKVector3Lerp(_p0, _p1, t);
	GLKVector3 P12 = GLKVector3Lerp(_p1, _p2, t);
	GLKVector3 P23 = GLKVector3Lerp(_p2, _p3, t);
	GLKVector3 P0112 = GLKVector3Lerp(P01, P12, t);
	GLKVector3 P1223 = GLKVector3Lerp(P12, P23, t);
	return GLKVector3Lerp(P0112, P1223, t);
}

@end
