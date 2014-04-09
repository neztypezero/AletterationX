//
//  NezNodeParticleEmitter.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/17.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezNode.h"
#import "NezVertexTypes.h"
#import "NezParticleSystemVAO.h"

@class NezGLSLProgramParticleSystem;

// structure to represent a particle
typedef struct {
	GLKVector4 pos; // w contains size
	GLKVector4 vel; // w contains size
	
	float angle;
	float angleVel;
	
	float life;
	float invLifespan;
	float invMass;
} NezNodeParticle;

@interface NezNodeParticleEmitter : SCNNode<SCNNodeRendererDelegate> {
	// System configuration
	GLKVector3 _initialLocationBoundsOrigin;
	GLKVector3 _initialLocationBoundsSize;
	GLKVector3 _initialVelocity;
	GLKVector3 _initialVelocityVariation;
	float	   _angularVelocity;
	float	   _angularVelocityVariation;
	float	   _initialSize;
	float	   _initialSizeVariation;
	float	   _terminalSize;
	float	   _terminalSizeVariation;
	float	   _lifespan;
	float	   _lifespanVariation; // percentage
	float	   _birthRate; // number of particles emitted per second
	float	   _birthRateVariation; // percentage
	
	// Actuators
	GLKVector3 _gravity;
	float	   _dampening;
	float	   _trailFactor;
	
	// NezNodeParticle data storage
	NSData *_particleData;
	NSInteger    _particlesMaxCount;
	
	// Emission management
	CFTimeInterval _lastUpdateTime;
	float		   _birthRateRemainder;
	
	// live particles
	NSData *_liveParticleData;
	GLsizei  _liveParticlesCount;
	
	GLKVector3 _bmin;
	GLKVector3 _bmax;
	
	// blend modes
	GLenum _srcBlend;
	GLenum _dstBlend;
	
	BOOL _enableZRead;
	BOOL _enableZWrite;
	
	// GL stuff
	BOOL _glIsInitialized;
	
	NezParticleSystemVAO *_particleSystemVao;

	NezVoidBlock _completionHandler;
}

// The position of the emission of particles (can be nil)
@property (nonatomic, retain) SCNNode *emitter;

@property (readonly, getter = particles) NezNodeParticle *particles;
@property (readonly, getter = liveParticles) int *liveParticles;

@property (nonatomic, readonly) BOOL hasStarted;

-(id)initWithMaxCount:(NSInteger)maxCount;
-(void)initGL;
-(void)dealloc;

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)elapsedTime;
-(void)sortWithViewDirection:(GLKVector3)viewDir;

-(void)initParticle:(NezNodeParticle*)p;
-(void)updateParticle:(NezNodeParticle*)p withTimeSinceLastUpdate:(CFTimeInterval)elapsedTime;

-(void)startEmitting;
-(void)stopEmitting;
-(void)stopSpawing;

@end
