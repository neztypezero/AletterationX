//
//  NezGeometry.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <GLKit/GLKit.h>
#import "NezGCD.h"
#import "NezGLKUtil.h"

@interface NezNode : SCNNode

@property (setter = setColor:, getter = color) SCNVector3 color;
@property (readonly, getter = dimensions) SCNVector3 dimensions;
@property (readonly, getter = size) GLKVector3 size;
@property (readonly, getter = orientation) GLKQuaternion orientation;
@property (readonly, getter = inverseOrientation) GLKQuaternion inverseOrientation;
@property (readonly, getter = glkTransform) GLKTransform glkTransform;

+(instancetype)nodeWithGeometry:(SCNGeometry*)geometry;

@end
