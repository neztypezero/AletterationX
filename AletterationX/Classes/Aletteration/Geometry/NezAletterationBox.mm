//
//  NezAletterationBox.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationBox.h"
#import "NezAletterationLetterBlock.h"
#import <BulletDynamics/btBulletDynamicsCommon.h>
#import "NezModelVertexArray.h"
#import "NezSurfaceColorMaterial.h"

@implementation NezAletterationBox

+(instancetype)box {
	return [[self alloc] init];
}

+(instancetype)lid {
	NezAletterationBox *lid = [[self alloc] init];
	lid.isLid = YES;
	return lid;
}

-(void)allocateDynamicObject {
	btQuaternion orientation = btQuaternion(0,0,0,1);
	SCNVector3 min, max;
	[self getBoundingBoxMin:&min max:&max];
	btScalar x = (max.x-min.x)/2.0;
	btScalar y = (max.y-min.y)/2.0;
	btScalar z = (max.z-min.z)/2.0;
	btScalar halfInsideThickness = self.insideThickness*0.5;
	btScalar sideThickness = self.sideThickness;
	btScalar halfSideThickness = sideThickness*0.5;
	
	btCompoundShape* shape = new btCompoundShape();
	if (!self.isLid) {
		shape->addChildShape(btTransform(orientation, btVector3(0.0, 0.0, halfInsideThickness-z)), [self makeBoxShapeWithHalfSideExtents:btVector3(x-sideThickness, y-sideThickness, halfInsideThickness)]); // box bottom
	} else {
		shape->addChildShape(btTransform(orientation, btVector3(0.0, 0.0, z-halfInsideThickness)), [self makeBoxShapeWithHalfSideExtents:btVector3(x-sideThickness, y-sideThickness, halfInsideThickness)]); // box top
	}
	shape->addChildShape(btTransform(orientation, btVector3(halfSideThickness-x, 0.0, 0.0)), [self makeBoxShapeWithHalfSideExtents:btVector3(halfSideThickness, y, z)]); // box left
	shape->addChildShape(btTransform(orientation, btVector3(x-halfSideThickness, 0.0, 0.0)), [self makeBoxShapeWithHalfSideExtents:btVector3(halfSideThickness, y, z)]); // box right
	shape->addChildShape(btTransform(orientation, btVector3(0.0, halfSideThickness-y, 0.0)), [self makeBoxShapeWithHalfSideExtents:btVector3(x, halfSideThickness, z)]); // box front
	shape->addChildShape(btTransform(orientation, btVector3(0.0, y-halfSideThickness, 0.0)), [self makeBoxShapeWithHalfSideExtents:btVector3(x, halfSideThickness, z)]); // box back
	
	SCNVector4 rotation = self.rotation;
	if (self.rotation.w != 0) {
		orientation.setRotation(btVector3(rotation.x, rotation.y, rotation.z), rotation.w);
	}
	SCNVector3 pos = self.position;
	btVector3 position = btVector3(pos.x, pos.y, pos.z);

	btDefaultMotionState* motionState = new btDefaultMotionState(btTransform(orientation, position));

	btScalar bodyMass = self.bodyMass;
	btVector3 bodyInertia(0.0, 0.0, 0.0);
	shape->calculateLocalInertia(bodyMass, bodyInertia);

	btRigidBody::btRigidBodyConstructionInfo bodyCI = btRigidBody::btRigidBodyConstructionInfo(bodyMass, motionState, shape, bodyInertia);

	bodyCI.m_restitution = self.restitution;
	bodyCI.m_friction = self.friction;
	bodyCI.m_angularDamping = self.angularDamping;
	bodyCI.m_linearDamping = self.linearDamping;

	btRigidBody* body = new btRigidBody(bodyCI);

	body->setUserPointer((__bridge void*)self);
	
	[self setRigidBody:body andCollisionShape:shape];
}

-(btBoxShape*)makeBoxShapeWithHalfSideExtents:(btVector3)extents {
	btBoxShape *boxShape = new btBoxShape(extents);
	boxShape->setMargin(0.0);
	return boxShape;
}

-(void)setColor:(SCNVector3)color {
	[super setColor:color];
	if (self.geometry && self.geometry.firstMaterial) {
		SCNMaterial *mat = self.geometry.firstMaterial;
		if ([mat isKindOfClass:[NezSurfaceColorMaterial class]]) {
			NezSurfaceColorMaterial *surfaceMaterial = (NezSurfaceColorMaterial*)mat;
			surfaceMaterial.mu_SurfaceColor = color;
		} else {
			NSColor *c = [NSColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0];
			mat.diffuse.contents = c;
			mat.ambient.contents = c;
		}
	}
}

-(CATransform3D)transformForLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	SCNVector3 size = letterBlock.dimensions;
	SCNVector3 boxSize = self.dimensions;
	float letterZ = (self.insideThickness*1.1)-((boxSize.z*0.5)-(size.x*0.5));
	CATransform3D matrix = CATransform3DTranslate(self.transform, -14.5*size.z+(size.z*letterBlock.boxRowIndex), size.x*1.025*letterBlock.boxColumnIndex, letterZ);
	return CATransform3DRotate(CATransform3DRotate(matrix, M_PI/2.0, 0.0, 1.0, 0.0), M_PI/2.0, 0.0, 0.0, 1.0);
}

-(CATransform3D)relativeTransformForLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	SCNVector3 size = letterBlock.dimensions;
	SCNVector3 boxSize = self.dimensions;
	float letterZ = (self.insideThickness*1.1)-((boxSize.z*0.5)-(size.x*0.5));
	CATransform3D matrix = CATransform3DMakeTranslation(-14.5*size.z+(size.z*letterBlock.boxRowIndex), size.x*1.025*letterBlock.boxColumnIndex, letterZ);
	return CATransform3DRotate(CATransform3DRotate(matrix, M_PI/2.0, 0.0, 1.0, 0.0), M_PI/2.0, 0.0, 0.0, 1.0);
}

-(CATransform3D)transformForLid:(NezAletterationBox*)lid {
	SCNVector3 boxSize = self.dimensions;
	SCNVector3 lidSize = lid.dimensions;
	return CATransform3DTranslate(self.transform, 0.0, 0.0, boxSize.z/2.0-lidSize.z/2.0+lid.insideThickness);
}

-(CATransform3D)transformForLid:(NezAletterationBox*)lid withBoxTransform:(CATransform3D)transform {
	SCNVector3 boxSize = self.dimensions;
	SCNVector3 lidSize = lid.dimensions;
	return CATransform3DTranslate(transform, 0.0, 0.0, boxSize.z/2.0-lidSize.z/2.0+lid.insideThickness);
}

-(GLKTransform)glkTransformForLid:(NezAletterationBox*)lid withBoxGLKTransform:(GLKTransform)transform {
	SCNVector3 boxSize = self.dimensions;
	SCNVector3 lidSize = lid.dimensions;
	GLKVector3 pos = GLKVector3Make(0.0, 0.0, boxSize.z/2.0-lidSize.z/2.0+lid.insideThickness);
	pos = GLKQuaternionRotateVector3(transform.orientation, pos);
	return GLKTransformMakeWithPositionAndOrientation(GLKVector3Add(transform.position, pos), transform.orientation);
}

@end
