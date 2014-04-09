//
//  NezCubicBezier.h
//  Aletteration
//
//  Created by David Nesbitt on 2/25/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezPath3d.h"

@interface NezPathCubicBezier3d : NezPath3d

@property(nonatomic) GLKVector3 p0;
@property(nonatomic) GLKVector3 p1;
@property(nonatomic) GLKVector3 p2;
@property(nonatomic) GLKVector3 p3;

+(instancetype)bezier;
+(instancetype)bezierWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3;
+(instancetype)bezierWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector3)p3;
+(instancetype)bezierWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector3)p3;

-(instancetype)initWithControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3;
-(instancetype)initWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector3)p3;
-(instancetype)initWithControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector3)p3;

-(void)setControlPointsP0:(GLKVector3)p0 P1:(GLKVector3)p1 P2:(GLKVector3)p2 P3:(GLKVector3)p3;
-(void)setControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector3)p3;
-(void)setControlPointsP0:(GLKVector3)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector3)p3;

@end
