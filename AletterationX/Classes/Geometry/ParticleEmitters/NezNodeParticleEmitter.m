//
//  NezNodeParticleEmitter.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/17.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNodeParticleEmitter.h"
#import "NezGLSLProgramParticleSystem.h"
#import "NezVertexParticleVBO.h"
#import "NezRandom.h"

@implementation NezNodeParticleEmitter

-(NezNodeParticle*)particles {
	return (NezNodeParticle*)_particleData.bytes;
}

-(int32_t*)liveParticles {
	return (int32_t*)_liveParticleData.bytes;
}

-(id)initWithMaxCount:(NSInteger)maxCount {
	if (self = [super init]) {
		_particlesMaxCount = maxCount;
		_particleData = [NSMutableData dataWithLength:sizeof(NezNodeParticle)*maxCount];
		_birthRateRemainder = 0;
		
		_liveParticleData = [NSMutableData dataWithLength:sizeof(int32_t)*maxCount];
		_liveParticlesCount = 0;
		
		_initialLocationBoundsOrigin = GLKVector3Make(0.f, 0.f, 0.f);
		_initialLocationBoundsSize = GLKVector3Make(0.1f, 0.f, .1f);
		_initialVelocity = GLKVector3Make(1, 4, 1);
		_initialVelocityVariation = GLKVector3Make(0.1, 0.2, 0.1);
		
		_srcBlend = GL_ONE;
		_dstBlend = GL_ONE;
		
		_angularVelocity = 0.1;
		_angularVelocityVariation = 0.5;
		
		_initialSize = 0.5;
		_initialSizeVariation = 0.2;
		_terminalSize = 3.0;
		_terminalSizeVariation = 1.0;
		
		_birthRate = 0.f;
		_birthRateVariation = 0.f;
		
		_lifespan = 5.f;
		_lifespanVariation = 0.5f;
		
		_lastUpdateTime = CFAbsoluteTimeGetCurrent();
		
		_gravity = GLKVector3Make(0.f, 0.f, -9.8f);
		_dampening = 0.f;
		_trailFactor = 0;

		[self setRendererDelegate:self];
	}
	return self;
}

-(void)startEmitting {
	_hasStarted = YES;
	[self setRendererDelegate:self];
}

-(void)stopEmitting {
	_completionHandler = nil;
	_hasStarted = NO;
	[self setRendererDelegate:nil];
}

-(void)stopSpawing {
	_birthRate = 0.f;
	_birthRateVariation = 0.f;
}

-(void)initGL {
	// fill triangle indices with the same vertex
	NSMutableData *vertexData = [NSMutableData dataWithLength:sizeof(NezVertexParticle)*_particlesMaxCount];
	NSMutableData *indexData = [NSMutableData dataWithLength:_particlesMaxCount * 3 * sizeof(GLint)];
	GLint* indices = (GLint*)indexData.bytes;
	for (int i = 0; i < _particlesMaxCount; ++i) {
		indices[i*3+0] = i;
		indices[i*3+1] = i;
		indices[i*3+2] = i;
	}
	NezVertexParticleVBO *vbo = [[NezVertexParticleVBO alloc] initWithVertexData:vertexData andIndexData:indexData];
	_particleSystemVao = [[NezParticleSystemVAO alloc] initWithVertexBufferObject:vbo];
	_particleSystemVao.program = [NezGLSLProgramParticleSystem program];
	
	_glIsInitialized = YES;
}

-(void)initParticle:(NezNodeParticle*)p {
	p->life = randomVariation(_lifespan, _lifespan * _lifespanVariation);
	p->invLifespan = 1.f / p->life;
	p->invMass = 1.f;
	
	p->pos.x = randomFloatBetween(-1.0, 1.0) * _initialLocationBoundsSize.x + _initialLocationBoundsOrigin.x;
	p->pos.y = randomFloatBetween(-1.0, 1.0) * _initialLocationBoundsSize.y + _initialLocationBoundsOrigin.y;
	p->pos.z = randomFloatBetween(-1.0, 1.0) * _initialLocationBoundsSize.z + _initialLocationBoundsOrigin.z;
	p->pos.w = randomVariation(_initialSize, _initialSizeVariation);
	
	if (_emitter) {
		SCNVector3 lPos = [self convertPosition:SCNVector3FromGLKVector3(*(GLKVector3*)&p->pos) fromNode:[_emitter presentationNode]];
		p->pos.x = lPos.x;
		p->pos.y = lPos.y;
		p->pos.z = lPos.z;
	}
	p->vel.x = randomVariation(_initialVelocity.x, _initialVelocityVariation.x);
	p->vel.y = randomVariation(_initialVelocity.y, _initialVelocityVariation.y);
	p->vel.z = randomVariation(_initialVelocity.z, _initialVelocityVariation.z);
	p->vel.w = (randomVariation(_terminalSize, _terminalSizeVariation) - p->pos.w) / p->life;
	
	p->angle = randomFloatBetween(-1.0, 1.0) * M_PI;
	p->angleVel = randomVariation(_angularVelocity, _angularVelocityVariation);
}

-(void)updateParticle:(NezNodeParticle*)p withTimeSinceLastUpdate:(CFTimeInterval)elapsedTime {
	GLKVector3 gravity = GLKVector3MultiplyScalar(_gravity, elapsedTime);
	
	float dtonmass = elapsedTime * p->invMass;
	
	// gravity
	p->vel.x += gravity.x;
	p->vel.y += gravity.y;
	p->vel.z += gravity.z;
	
	// dampening
	float dampdt = _dampening * dtonmass;
	p->vel.x -= dampdt * p->vel.x;
	p->vel.y -= dampdt * p->vel.y;
	p->vel.z -= dampdt * p->vel.z;
	
	p->pos.x += p->vel.x * elapsedTime;
	p->pos.y += p->vel.y * elapsedTime;
	p->pos.z += p->vel.z * elapsedTime;
	p->pos.w += p->vel.w * elapsedTime;
	p->angle += p->angleVel * elapsedTime;
	
	// update Bonding Box
	if (p->pos.x < _bmin.x)
		_bmin.x = p->pos.x;
	if (p->pos.y < _bmin.y)
		_bmin.y = p->pos.y;
	if (p->pos.z < _bmin.z)
		_bmin.z = p->pos.z;
	
	if (p->pos.x > _bmax.x)
		_bmax.x = p->pos.x;
	if (p->pos.y > _bmax.y)
		_bmax.y = p->pos.y;
	if (p->pos.z > _bmax.z)
		_bmax.z = p->pos.z;
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)elapsedTime {
	// Compute emission count
	float newCount = elapsedTime * _birthRate;
	newCount = randomVariation(newCount, newCount * _birthRateVariation);
	newCount += _birthRateRemainder;
	float intCount = truncf(newCount);
	_birthRateRemainder = newCount - intCount;
	
	// Update existing ones and generate new ones
	_bmin = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
	_bmax = GLKVector3Make(FLT_MIN, FLT_MIN, FLT_MIN);
	GLsizei liveCount = 0;
	for (int i = 0; i < _particlesMaxCount; ++i) {
		NezNodeParticle *p = self.particles+i;//
		if (p->life > elapsedTime) { // still alive
			p->life -= elapsedTime;
			[self updateParticle:p withTimeSinceLastUpdate:elapsedTime];
			self.liveParticles[liveCount++] = i;
		} else { // particle's dead
			if (intCount > 0.f) { // create a new one
				intCount -= 1.f;
				[self initParticle:p];
				self.liveParticles[liveCount++] = i;
			} else {
				if (p->life != 0.f) {
					p->life = 0.f; // ensure dead particle have 0 lifespan
				}
			}
		}
	}
	_liveParticlesCount = liveCount;
	
	// Update the SCNNode bounding box
	SCNVector3 bmin = SCNVector3FromGLKVector3(_bmin);
	SCNVector3 bmax = SCNVector3FromGLKVector3(_bmax);
	[self setBoundingBoxMin:&bmin max:&bmax];
}

// Sort the live particles along the view direction
-(void)sortWithViewDirection:(GLKVector3)viewDir {
	int *liveParticles = self.liveParticles;
	NezNodeParticle *particles = self.particles;
	qsort_b(liveParticles, _liveParticlesCount, sizeof(int), ^int(const void* a, const void* b) {
		NezNodeParticle* pa = particles + *(int *)a;
		NezNodeParticle* pb = particles + *(int *)b;
		float aDot = GLKVector3DotProduct(viewDir, *(GLKVector3*)&pa->pos);
		float bDot = GLKVector3DotProduct(viewDir, *(GLKVector3*)&pb->pos);
		return (aDot < bDot) ? -1 : 1;
	});
}

// invoked when updating the VBO with the current live particles
-(void)prepareVBO:(GLuint)vbo {
	// Update VBO, filling vertices in the back to front order
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	// Buffer orphaning
	glBufferData(GL_ARRAY_BUFFER, sizeof(NezVertexParticle) * _particlesMaxCount, NULL, GL_STREAM_DRAW);
	// Map the vbo on CPU memory
	NezVertexParticle* vboVertices = (NezVertexParticle*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
	if (vboVertices) {
		NezNodeParticle *particles = self.particles;
		int *liveParticles = self.liveParticles;
		for (int i = 0; i < _liveParticlesCount; ++i) {
			NezNodeParticle *p = particles+liveParticles[i];
			
			vboVertices[i].position = p->pos;
			vboVertices[i].velocity = *(GLKVector3 *)&p->vel;
			vboVertices[i].uv.x = p->angle;
			vboVertices[i].uv.y = 1.f - p->life * p->invLifespan;
		}
		// unmap the buffer
		glUnmapBuffer(GL_ARRAY_BUFFER);
	}
	// unbind the VBO, to avoid someone else messing with it
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

// invoked by SceneKit with "node" has to be rendered
-(void)renderNode:(SCNNode *)node renderer:(SCNRenderer *)renderer arguments:(NSDictionary *)arguments {
	// if no particles are alive, nothing to render -> exit
	if (_liveParticlesCount == 0) {
		return;
	}
	// lazy GL initialization, to ensure that we are creating our resources
	// on the GL context that will effectively be used to render
	if (!_glIsInitialized) {
		[self initGL];
	}
	
//	// Sort the particles, in the front to back order
//    GLKVector3 localView = SCNVector3ToGLKVector3([node convertPosition:SCNVector3Make(0,0,0) fromNode:renderer.pointOfView]);
//    [self sortWithViewDirection:GLKVector3Normalize(localView)];
	
	// upload particle vertices in VBO
	[self prepareVBO:_particleSystemVao.vertexBufferObject.vertexBufferObject];
	
	// Prevent depth buffer reading if needed
	if (!_enableZRead)
		glDisable(GL_DEPTH_TEST);
	
	// Prevent depth buffer writing if needed
	if (!_enableZWrite)
		glDepthMask(false);
	
	// Enable blending (customizable per system)
	glEnable(GL_BLEND);
	glBlendFunc(_srcBlend, _dstBlend);
	
	_particleSystemVao.trailFactor = _trailFactor;
	_particleSystemVao.liveParticlesCount = _liveParticlesCount;
	_particleSystemVao.mv = GLKMatrix4FromCATransform3D([[arguments objectForKey:SCNModelViewTransform] CATransform3DValue]);
	_particleSystemVao.proj = GLKMatrix4FromCATransform3D([[arguments objectForKey:SCNProjectionTransform] CATransform3DValue]);

	[_particleSystemVao draw];
	
	// Unbind samplers
	unbindTexture2D(GL_TEXTURE0);
	unbindTexture2D(GL_TEXTURE1);
	
	// Restore default states
	glDisable(GL_BLEND);
	if (!_enableZRead)
		glEnable(GL_DEPTH_TEST);
	if (!_enableZWrite)
		glDepthMask(true);
}

-(void)dealloc {
	NSLog(@"dealooc emitter");
	
	self.rendererDelegate = nil;
	
	_particleSystemVao = nil;
	
	_particleData = nil;
	_liveParticleData = nil;
}

@end
