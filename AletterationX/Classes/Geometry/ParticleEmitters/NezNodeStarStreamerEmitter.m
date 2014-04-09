//
//  NezNodeStarStreamerEmitter.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/19.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNodeStarStreamerEmitter.h"
//#import "NezDynamicNode.h"

@implementation NezNodeStarStreamerEmitter

-(void)setupStreamerWithTexture:(GLuint)texture ColorRamp:(GLuint)colorRamp andCompletionHandler:(NezVoidBlock)completionHandler {
	_completionHandler = completionHandler;
	
	memset(self.particles, 0, sizeof(NezNodeParticle) * _particlesMaxCount);
	
	_initialLocationBoundsOrigin = GLKVector3Make(0.0f, 0.f, 0.f);
	_initialLocationBoundsSize = GLKVector3Make(1.5f, 1.5f, 1.5f);
	
	_initialVelocity = GLKVector3Make(0.0, 0.0, 0.0);
	_initialVelocityVariation = GLKVector3Make(5.0, 5.0, 1.5);
	
	_angularVelocity = 0.1;
	_angularVelocityVariation = 3.5;
	
	_srcBlend = GL_SRC_ALPHA;
	_dstBlend = GL_ONE;
	
	_enableZRead = YES;
	_enableZWrite = NO;
	
	_initialSize = 0.25;
	_initialSizeVariation = 0.1;
	_terminalSize = 0.05;
	_terminalSizeVariation = 0.05;
	
	_birthRate = 300;
	_birthRateVariation = 0.6f;
	
	_lifespan = 1.0f;
	_lifespanVariation = 0.5f;
	
	_dampening = 0.2f;
	_gravity = GLKVector3Make(0.f, 0.f, 0.0f);
	
	_trailFactor = 0.0;

	_particleSystemVao.tex = texture;
	_particleSystemVao.ramp = colorRamp;
}

//-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)elapsedTime {
//	if (self.emitter) {
//		if ([self.emitter isKindOfClass:[NezDynamicNode class]]) {
//			NezDynamicNode *dynamicNode = (NezDynamicNode*)self.emitter;
//			btVector3 v = dynamicNode.rigidBody->getLinearVelocity();
//			_initialVelocity = GLKVector3Make(-v.x(), -v.y(), -v.z());
//			_initialVelocityVariation = GLKVector3Make(fabs(v.x())*0.1, fabs(v.y())*0.1, fabs(v.z())*0.1);
//		}
//	}
//	[super updateWithTimeSinceLastUpdate:elapsedTime];
//}

@end
