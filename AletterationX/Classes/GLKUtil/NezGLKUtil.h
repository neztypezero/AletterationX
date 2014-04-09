//
//  NezGLKUtil.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

#ifndef Aletteration3_NezGLKUtil_h
#define Aletteration3_NezGLKUtil_h

#ifdef __cplusplus
extern "C" {
#endif
	
	typedef struct GLKTransform {
		GLKVector3 position;
		GLKQuaternion orientation;
	} GLKTransform;

	static inline GLKMatrix4 GLKMatrix4MakeWithGLKTransform(GLKTransform transform) {
		GLKMatrix4 matrix = GLKMatrix4MakeWithQuaternion(transform.orientation);
		matrix.m30 = transform.position.x;
		matrix.m31 = transform.position.y;
		matrix.m32 = transform.position.z;
		return matrix;
	}
	
	static inline GLKTransform GLKTransformMakeWithGLKMatrix4(GLKMatrix4 matrix) {
		GLKTransform transform;
		transform.orientation = GLKQuaternionMakeWithMatrix4(matrix);
		transform.position = GLKVector3Make(matrix.m30, matrix.m31, matrix.m32);
		return transform;
	}
	
	static inline GLKTransform GLKTransformMakeWithPositionAndOrientation(GLKVector3 position, GLKQuaternion orientation) {
		GLKTransform transform;
		transform.orientation = orientation;
		transform.position = position;
		return transform;
	}
	
	static inline GLKVector3 pitchRollYawVectorFromQuaternion(GLKQuaternion o) {
		float pitch = atan2(2*o.x*o.w - 2*o.y*o.z, 1 - 2*o.x*o.x - 2*o.z*o.z); // x axis
		float roll  = atan2(2*o.y*o.w - 2*o.x*o.z, 1 - 2*o.y*o.y - 2*o.z*o.z); // y axis
		float yaw   =  asin(2*o.x*o.y + 2*o.z*o.w);                            // z axis

		return GLKVector3Make(pitch, roll, yaw);
	}

	
#endif
	
#ifdef __cplusplus
}
#endif