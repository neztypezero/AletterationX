//
//  NezNodeFireworksEmitter.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/17.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNodeFireworksEmitter.h"
#import "NezGLSLProgramParticleSystem.h"
#import "NezRandom.h"

static inline GLKVector3 randomUnitSpherePoint() {
	float u = randomFloat();
	float v = randomFloat();
	float theta = 2 * M_PI * u;
	float phi = acos(2 * v - 1);
	float x = (sin(phi) * cos(theta));
	float y = (sin(phi) * sin(theta));
	float z = (cos(phi));
	return GLKVector3Make(x, y, z);
}

@implementation NezNodeFireworksEmitter

-(void)startEmitting {
	[self initAllParticles];
	[super startEmitting];
}

-(void)setupFireworksWithTexture:(GLuint)texture ColorRamp:(GLuint)colorRamp andCompletionHandler:(NezVoidBlock)completionHandler {
	_completionHandler = completionHandler;
	
	memset(self.particles, 0, sizeof(NezNodeParticle) * _particlesMaxCount);
	
	_initialLocationBoundsOrigin = GLKVector3Make(0.f, 0.f, 0.f);
	_initialLocationBoundsSize = GLKVector3Make(0.0f, 0.0f, 0.0f);
	
	_initialVelocity = GLKVector3Make(10.0, 10.0, 10.0);
	_initialVelocityVariation = GLKVector3Make(2.5, 2.5, 2.5);
	
	_angularVelocity = 0.1;
	_angularVelocityVariation = 3.5;
	
	_srcBlend = GL_SRC_ALPHA;
	_dstBlend = GL_ONE;
	
	_enableZRead = YES;
	_enableZWrite = NO;
	
	_initialSize = 0.15;
	_initialSizeVariation = 0.05;
	_terminalSize = 0.05;
	_terminalSizeVariation = 0.05;
	
	_birthRate = _particlesMaxCount*_particlesMaxCount;
	_birthRateVariation = 0.0f;
	
	_lifespan = 1.5f;
	_lifespanVariation = 0.0f;
	
	_dampening = 0.2f;
	_gravity = GLKVector3Make(0.f, 0.f, -9.8f);
	_trailFactor = 0.0;
	
	_particleSystemVao.tex = texture;
	_particleSystemVao.ramp = colorRamp;
}

-(void)initAllParticles {
	float length = GLKVector3Length(_initialVelocityVariation);
	float extraVelocity = randomFloatInRange(-length, length*2.0);
	_initialVelocity = GLKVector3Add(_initialVelocity, GLKVector3Make(extraVelocity, extraVelocity, extraVelocity));
	
	//start all particles
	NezNodeParticle *particles = self.particles;//
	for (int i = 0; i < _particlesMaxCount; ++i) {
		[self initParticle:particles+i];
		self.liveParticles[i] = i;
	}
}

-(void)initParticle:(NezNodeParticle*)p {
	p->life = randomVariation(_lifespan, _lifespan * _lifespanVariation);
	p->invLifespan = 1.f / p->life;
	p->invMass = 1.f;
	
	p->pos.x = 0.0;
	p->pos.y = 0.0;
	p->pos.z = 0.0;
	p->pos.w = randomVariation(_initialSize, _initialSizeVariation);
	
	if (self.emitter) {
		SCNVector3 lPos = [self convertPosition:SCNVector3FromGLKVector3(*(GLKVector3*)&p->pos) fromNode:[self.emitter presentationNode]];
		p->pos.x = lPos.x;
		p->pos.y = lPos.y;
		p->pos.z = lPos.z;
	}
	GLKVector3 v = GLKVector3Multiply(randomUnitSpherePoint(), _initialVelocity);
	
	p->vel.x = v.x;
	p->vel.y = v.y;
	p->vel.z = v.z;
	p->vel.w = (randomVariation(_terminalSize, _terminalSizeVariation) - p->pos.w) / p->life;
	
	p->angle = randomFloatBetween(-1.0, 1.0) * M_PI;
	p->angleVel = randomVariation(_angularVelocity, _angularVelocityVariation);
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)elapsedTime {
	// Update existing ones and generate new ones
	_bmin = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
	_bmax = GLKVector3Make(FLT_MIN, FLT_MIN, FLT_MIN);
	GLsizei liveCount = 0;
	NezNodeParticle *particles = self.particles;
	for (int i = 0; i < _particlesMaxCount; ++i) {
		NezNodeParticle *p = particles+i;//
		if (p->life > elapsedTime) { // still alive
			p->life -= elapsedTime;
			[self updateParticle:p withTimeSinceLastUpdate:elapsedTime];
			self.liveParticles[liveCount++] = i;
		} else { // particle's dead
			if (p->life != 0.f) {
				p->life = 0.f; // ensure dead particle have 0 lifespan
			}
		}
	}
	_liveParticlesCount = liveCount;
	
	// Update the SCNNode bounding box
	SCNVector3 bmin = SCNVector3FromGLKVector3(_bmin);
	SCNVector3 bmax = SCNVector3FromGLKVector3(_bmax);
	[self setBoundingBoxMin:&bmin max:&bmax];
	
	if (_liveParticlesCount == 0) {
		if (_completionHandler) {
			[NezGCD dispatchBlock:_completionHandler];
		} else {
			[self initAllParticles];
		}
	}
}

@end
