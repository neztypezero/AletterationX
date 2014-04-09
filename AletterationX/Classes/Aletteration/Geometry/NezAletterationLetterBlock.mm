//
//  NezAletterationLetterBlock.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterBlock.h"
#import "NezSurfaceColorMaterial.h"
#import "NezCIFilterGlow.h"
#import <BulletDynamics/btBulletDynamicsCommon.h>

@implementation NezAletterationLetterBlock

-(void)allocateDynamicObject {
	btQuaternion orientation = btQuaternion(0,0,0,1);
	SCNVector3 dimensions = self.dimensions;
	btScalar x = dimensions.x/2.0;
	btScalar y = dimensions.y/2.0;
	btScalar z = dimensions.z/2.0;
	
	btBoxShape *boxShape = new btBoxShape(btVector3(x, y, z));
	
	SCNVector4 rotation = self.rotation;
	if (self.rotation.w != 0) {
		orientation.setRotation(btVector3(rotation.x, rotation.y, rotation.z), rotation.w);
	}
	SCNVector3 pos = self.position;
	btVector3 position = btVector3(pos.x, pos.y, pos.z);
	
	btDefaultMotionState* motionState = new btDefaultMotionState(btTransform(orientation, position));
	
	btScalar bodyMass = self.bodyMass;
	btVector3 bodyInertia(0.0, 0.0, 0.0);
	boxShape->calculateLocalInertia(bodyMass, bodyInertia);
	
	btRigidBody::btRigidBodyConstructionInfo bodyCI = btRigidBody::btRigidBodyConstructionInfo(bodyMass, motionState, boxShape, bodyInertia);
	
	bodyCI.m_restitution = self.restitution;
	bodyCI.m_friction = self.friction;
	bodyCI.m_angularDamping = self.angularDamping;
	bodyCI.m_linearDamping = self.linearDamping;
	
	btRigidBody* body = new btRigidBody(bodyCI);

//	body->setLinearFactor(btVector3(0,0,1));
	body->setUserPointer((__bridge void*)self);
	
	[self setRigidBody:body andCollisionShape:boxShape];
}

+(instancetype)blockWithLetter:(char)letter andFrontMaterial:(NezSurfaceColorMaterial*)frontMaterial {
	return [[self alloc] initWithLetter:letter andFrontMaterial:frontMaterial];
}

-(instancetype)initWithLetter:(char)letter andFrontMaterial:(NezSurfaceColorMaterial*)frontMaterial {
	if ((self = [super init])) {
		self.frontMaterial = frontMaterial;
		self.letter = letter;
		self.collisionMinBounce = GLKVector3Make(-0.5, -0.5, -0.5);
		self.collisionMaxBounce = GLKVector3Make( 0.5,  0.5,  0.5);
	}
	return self;
}

-(void)setColor:(SCNVector3)color {
	[super setColor:color];
	_frontMaterial.mu_SurfaceColor = color;
	if (getLuma(color) < 0.5) {
		_frontMaterial.mu_DiffuseTintColor = SCNVector3Make(1.0, 1.0, 1.0);
	} else {
		_frontMaterial.mu_DiffuseTintColor = SCNVector3Make(0.0, 0.0, 0.0);
	}
}

-(void)setLetter:(char)letter {
	_letter = letter;
	
	CATransform3D uvTransform = [self textureCoordTransformForLetter:letter isLowerCase:self.isLowerCase];
	self.frontMaterial.diffuse.contentsTransform = uvTransform;
	self.frontMaterial.ambient.contentsTransform = uvTransform;
	self.frontMaterial.normal.contentsTransform = uvTransform;
}

-(void)setIsLowerCase:(BOOL)isLowerCase {
	_isLowerCase = isLowerCase;
	[self setLetter:self.letter];
}

-(CATransform3D)textureCoordTransformForLetter:(char)letter isLowerCase:(BOOL)isLowerCase {
	if (letter < 'a' && letter > 'z') {
		letter = 'a';
	}
	NSInteger index = letter-'a';
	NSInteger x = index%8;
	NSInteger y = index/8;
	
	if (isLowerCase) {
		y += 4;
	}
	return CATransform3DTranslate(CATransform3DMakeScale(0.125, 0.125, 1.0), x, y, 0.0);
}

// highlight the node at index 'index' in the grid by setting a CI filter
-(void)addAnimatingHighlight {
	[NezGCD dispatchBlock:^{
		//allocate a glow filter
		NezCIFilterGlow *glowFilter = [[NezCIFilterGlow alloc] init];
		glowFilter.name = @"aGlow";
		[glowFilter setDefaults];
		[glowFilter setValue:@5 forKey:@"inputRadius"];
		[glowFilter setValue:[NSColor colorWithRed:self.color.x green:self.color.y blue:self.color.z alpha:1.0] forKey:@"color"];
		
		// Set the filter
		self.filters = @[glowFilter];
		
		// Animate the radius parameter of the glow filter
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.aGlow.inputRadius"];
		animation.toValue = @50;
		animation.fromValue = @5;
		animation.autoreverses = YES;
		animation.repeatCount = FLT_MAX;
		animation.duration = 2.0;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[self addAnimation:animation forKey:@"filterAnimation"];
	}];
}

-(void)removeAnimatingHighlight {
	[self removeAnimationForKey:@"filterAnimation"];
	self.filters = nil;
}

-(void)dealloc {
	if (self.frontMaterial) {
		self.frontMaterial.shaderModifiers = nil;
		self.frontMaterial = nil;
	}
}

@end
