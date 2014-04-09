//
//  NezAletterationBulletPhysics.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/10.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <BulletDynamics/btBulletDynamicsCommon.h>

#import <BulletCollision/CollisionDispatch/btSphereSphereCollisionAlgorithm.h>
#import <BulletCollision/CollisionDispatch/btSphereTriangleCollisionAlgorithm.h>
#import <BulletCollision/CollisionDispatch/btSimulationIslandManager.h>

#import "NezGCD.h"

#import "NezAletterationBulletPhysics.h"
#import "NezModelVertexArray.h"
#import "NezDynamicNode.h"
#import "NezGCD.h"

@interface NezContinuousForceApplication : NSObject

@property NezDynamicNode* node;
@property SCNVector3 forceVector;
@property SCNVector3 relativePosition;
@property CFTimeInterval timeRemaining;
@property (copy) NezForceCompletionHandler completionHandler;

+(instancetype)forceApplication;

@end

@implementation NezContinuousForceApplication

+(instancetype)forceApplication {
	return [[self alloc] init];
}

@end

@interface Nez6DofConstraint : NSObject

@property (readonly, getter = constraint) btGeneric6DofConstraint *constraint;

@end

@implementation Nez6DofConstraint {
	btGeneric6DofConstraint *_constraint;
}

+(instancetype)constraintWithBulletConstraint:(btGeneric6DofConstraint*)constraint {
	return [[self alloc] initWithBulletConstraint:constraint];
}

-(instancetype)initWithBulletConstraint:(btGeneric6DofConstraint*)constraint {
	if ((self = [super init])) {
		_constraint = constraint;
	}
	return self;
}

-(btGeneric6DofConstraint*)constraint {
	return _constraint;
}

-(void)dealloc {
	if (_constraint) {
		delete _constraint;
	}
}

@end

@implementation NezAletterationBulletPhysics {
	btBroadphaseInterface *_broadphase;
	btCollisionDispatcher *_dispatcher;
	btDefaultCollisionConfiguration *_collisionConfiguration;
	btConstraintSolver *_solver;
	btDiscreteDynamicsWorld *_dynamicsWorld;
	
	btCollisionShape *_floor;
	
	NSMutableDictionary *_constraintDictionary;
	
	dispatch_queue_t _dynamicsQueue;
}

+(instancetype)physicsWithDynamicNodeList:(NSArray*)dynamicNodeList {
	return [[self alloc] initWithDynamicNodeList:dynamicNodeList];
}

-(instancetype)initWithDynamicNodeList:(NSArray*)dynamicNodeList {
	if ((self = [super init])) {
		_dynamicsQueue = dispatch_queue_create("nez.Aletteration.DynamicsSerialQueue", DISPATCH_QUEUE_SERIAL);

		_constraintDictionary = [NSMutableDictionary dictionary];

		_broadphase = new btDbvtBroadphase();
		_collisionConfiguration = new btDefaultCollisionConfiguration();
		_dispatcher = new btCollisionDispatcher(_collisionConfiguration);

		_solver = new btSequentialImpulseConstraintSolver();
		int minimumSolverBatchSize = 256;
		
		_dynamicsWorld = new btDiscreteDynamicsWorld(_dispatcher, _broadphase, _solver, _collisionConfiguration);
		_dynamicsWorld->getSolverInfo().m_minimumSolverBatchSize = minimumSolverBatchSize;
		_dynamicsWorld->setGravity(btVector3(0, 0.0, -9.8));
		
		[self addFloor];
		[self addDynamicObjects:dynamicNodeList];
	}
	return self;
}

-(void)stepSimulationWithElapsedTime:(CFTimeInterval)elapsedTime {
	_dynamicsWorld->stepSimulation(elapsedTime, 2, 1.0/60.0);

	int numManifolds = _dynamicsWorld->getDispatcher()->getNumManifolds();
	for (int i=0;i<numManifolds;i++) {
		btPersistentManifold* contactManifold = _dynamicsWorld->getDispatcher()->getManifoldByIndexInternal(i);

		int numContacts = contactManifold->getNumContacts();
		if (numContacts > 0) {
			const btCollisionObject* obA = contactManifold->getBody0();
			const btCollisionObject* obB = contactManifold->getBody1();
			
			NezDynamicNode *nodeA = (__bridge NezDynamicNode*)obA->getUserPointer();
			NezDynamicNode *nodeB = (__bridge NezDynamicNode*)obB->getUserPointer();
			if (nodeA && nodeB) {
				[nodeA addCollisionNode:nodeB];
				[nodeB addCollisionNode:nodeA];
			}
		}
	}
}

-(void)addFloor {
	btCollisionShape *ground = new btStaticPlaneShape(btVector3(0,0,1), 0);
	btDefaultMotionState* groundMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),btVector3(0,0,0)));
	btRigidBody::btRigidBodyConstructionInfo groundRigidBodyCI(0, groundMotionState, ground, btVector3(0,0,0));
	groundRigidBodyCI.m_restitution = 0.25f;
	groundRigidBodyCI.m_friction = 0.9f;
	btRigidBody* groundRigidBody = new btRigidBody(groundRigidBodyCI);
	_dynamicsWorld->addRigidBody(groundRigidBody);
	
	_floor = ground;
}

-(void)addDynamicObjects:(NSArray*)objectList {
	for (NezDynamicNode *dynamicNode in objectList) {
		btRigidBody *rigidBody = (btRigidBody*)dynamicNode.rigidBody;
		if (rigidBody) {
			_dynamicsWorld->addRigidBody(rigidBody);
		}
	}
}

-(void)addNoMoveConstraintForNode:(NezDynamicNode*)node withKey:(NSString*)key {
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		btRigidBody *rigidBody = (btRigidBody*)node.rigidBody;
		btGeneric6DofConstraint *constraint = new btGeneric6DofConstraint(*(rigidBody), btTransform::getIdentity(), true);
		
		constraint->setAngularLowerLimit(btVector3(0,0,0));
		constraint->setAngularUpperLimit(btVector3(0,0,0));

		constraint->setLinearLowerLimit(btVector3(0,0,0));
		constraint->setLinearUpperLimit(btVector3(0,0,0));
		
		constraint->setLimit(0, 0, 0);
		constraint->setLimit(1, 0, 0);
		constraint->setLimit(2, 0, 0);
		constraint->setLimit(3, 0, 0);
		constraint->setLimit(4, 0, 0);
		constraint->setLimit(5, 0, 0);
		
		_dynamicsWorld->addConstraint(constraint);
		_constraintDictionary[[key copy]] = [Nez6DofConstraint constraintWithBulletConstraint:constraint];
	}];
}

-(void)addConstraintStickNodeA:(NezDynamicNode*)nodeA toNodeB:(NezDynamicNode*)nodeB withKey:(NSString*)key {
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		btRigidBody *rigidBodyA = (btRigidBody*)nodeA.rigidBody;
		btRigidBody *rigidBodyB = (btRigidBody*)nodeB.rigidBody;
		btGeneric6DofConstraint *constraint = new btGeneric6DofConstraint(*rigidBodyA, *rigidBodyB, btTransform::getIdentity(), btTransform::getIdentity(), true);
		constraint->setAngularLowerLimit(btVector3(0,0,0));
		constraint->setAngularUpperLimit(btVector3(0,0,0));
		
		constraint->setLimit(0, 0, 0);
		constraint->setLimit(1, 0, 0);
		constraint->setLimit(2, 0, 0);
		constraint->setLimit(3, 0, 0);
		constraint->setLimit(4, 0, 0);
		constraint->setLimit(5, 0, 0);
		
		_dynamicsWorld->addConstraint(constraint);
		_constraintDictionary[[key copy]] = [Nez6DofConstraint constraintWithBulletConstraint:constraint];
	}];
}

-(void)addConstraintForNode:(NezDynamicNode*)node withKey:(NSString*)key {
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		btRigidBody *rigidBody = (btRigidBody*)node.rigidBody;
		btGeneric6DofConstraint *constraint = new btGeneric6DofConstraint(*rigidBody, btTransform::getIdentity(), true);
		constraint->setAngularLowerLimit(btVector3(0,0,0));
		constraint->setAngularUpperLimit(btVector3(0,0,0));
		
		constraint->setLimit(0, -SIMD_INFINITY, SIMD_INFINITY);
		constraint->setLimit(1, -SIMD_INFINITY, SIMD_INFINITY);
		constraint->setLimit(2, -SIMD_INFINITY, SIMD_INFINITY);
		constraint->setLimit(3, 0, 0);
		constraint->setLimit(4, 0, 0);
		constraint->setLimit(5, 0, 0);
		
		_dynamicsWorld->addConstraint(constraint);
		_constraintDictionary[[key copy]] = [Nez6DofConstraint constraintWithBulletConstraint:constraint];
	}];
}

-(void)removeConstraintForKey:(NSString*)key {
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		Nez6DofConstraint *constraint = _constraintDictionary[key];
		if (constraint) {
			_dynamicsWorld->removeConstraint(constraint.constraint);
			[_constraintDictionary removeObjectForKey:key];
		}
	}];
}

-(btDiscreteDynamicsWorld*)dynamicsWorld {
	return _dynamicsWorld;
}

-(dispatch_queue_t)dynamicsQueue {
	return _dynamicsQueue;
}

-(void)dealloc {
	//remove the rigid bodies from the dynamics world
	for (int i=_dynamicsWorld->getNumCollisionObjects()-1; i>=0 ; i--) {
		btCollisionObject * obj = _dynamicsWorld->getCollisionObjectArray()[i];
		_dynamicsWorld->removeCollisionObject(obj);
	}
	delete _dynamicsWorld;
	delete _solver;
	delete _dispatcher;
	delete _collisionConfiguration;
	delete _broadphase;
	delete _floor;
}

@end
