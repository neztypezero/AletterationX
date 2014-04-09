//
//  NezGeometry.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@implementation NezNode {
	SCNVector3 _color;
}

+(instancetype)nodeWithGeometry:(SCNGeometry*)geometry {
	NezNode *node = [[NezNode alloc] init];
	node.geometry = geometry;
	return node;
}

-(void)setColor:(SCNVector3)color {
	_color = color;
}

-(SCNVector3)color {
	return _color;
}

-(SCNVector3)dimensions {
	SCNVector3 min, max;
	[self getBoundingBoxMin:&min max:&max];
	SCNVector3 dimensions = SCNVector3Make(max.x-min.x, max.y-min.y, max.z-min.z);
	return dimensions;
}

-(GLKVector3)size {
	GLKVector3 size = SCNVector3ToGLKVector3(self.dimensions);
	GLKVector3 scale = SCNVector3ToGLKVector3(self.scale);
	return GLKVector3Multiply(size, scale);
}

-(GLKQuaternion)orientation {
	CATransform3D t = self.transform;
	GLKQuaternion orientation = GLKQuaternionMakeWithMatrix3(GLKMatrix3Make(t.m11, t.m12, t.m13, t.m21, t.m22, t.m23, t.m31, t.m32, t.m33));
	return GLKQuaternionNormalize(orientation);
}

-(GLKQuaternion)inverseOrientation {
	CATransform3D t = self.transform;
	GLKQuaternion orientation = GLKQuaternionMakeWithMatrix3(GLKMatrix3Make(t.m11, t.m12, t.m13, t.m21, t.m22, t.m23, t.m31, t.m32, t.m33));
	return GLKQuaternionNormalize(GLKQuaternionInvert(orientation));
}

-(GLKTransform)glkTransform {
	return GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(self.transform));
}

@end
