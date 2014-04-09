//
//  NezPathCubicBezier2d.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezPath2d.h"

@interface NezPathCubicBezier2d : NezPath2d

@property(nonatomic) GLKVector2 p0;
@property(nonatomic) GLKVector2 p1;
@property(nonatomic) GLKVector2 p2;
@property(nonatomic) GLKVector2 p3;

+(instancetype)bezier;
+(instancetype)bezierWithControlPointsP0:(GLKVector2)p0 P1:(GLKVector2)p1 P2:(GLKVector2)p2 P3:(GLKVector2)p3;
+(instancetype)bezierWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector2)p3;
+(instancetype)bezierWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector2)p3;

-(instancetype)initWithControlPointsP0:(GLKVector2)p0 P1:(GLKVector2)p1 P2:(GLKVector2)p2 P3:(GLKVector2)p3;
-(instancetype)initWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector2)p3;
-(instancetype)initWithControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector2)p3;

-(void)setControlPointsP0:(GLKVector2)p0 P1:(GLKVector2)p1 P2:(GLKVector2)p2 P3:(GLKVector2)p3;
-(void)setControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P2Z:(float)p2Z P3:(GLKVector2)p3;
-(void)setControlPointsP0:(GLKVector2)p0 P1Z:(float)p1Z P1T:(float)p1T P2Z:(float)p2Z P2T:(float)p2T P3:(GLKVector2)p3;

@end
