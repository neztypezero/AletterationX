//
//  NezDynamicNode.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/11.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezDynamicNode.h"
#import "NezGLKUtil.h"
#import "NezRandom.h"
#import <LinearMath/btTransformUtil.h>
#import <BulletDynamics/btBulletDynamicsCommon.h>

#define btVec2(vec) btVector2(vec.x, vec.y)
#define btVec3(vec) btVector3(vec.x, vec.y, vec.z)
#define btVec4(vec) btVector4(vec.x, vec.y, vec.z, vec.w)

#define btQuat4(q) btQuaternion(q.x, q.y, q.z, q.w)

typedef enum NezDynamicStepActions {
	NEZ_ACTION_DO_NOTHING = 0,
	NEZ_ACTION_HOVER = 1,
	NEZ_ACTION_MOVE_NEAR = 2,
} NezDynamicStepAction;

@implementation NezDynamicNode {
	btRigidBody* _rigidBody;
	btCollisionShape *_collisionShape;

	btVector3 _hoverToOffset;
	GLKQuaternion _hoverToOrientation;
	bool _wantsOrientationToChange;
	GLKQuaternion _relativeOrientation;
	NezVoidBlock _hoverMovementCompletionHandler;
	SCNNode *_hoverToNode;
	float _movementTimeout;
	BOOL _hasTimeout;
	
	btVector3 _moveToPosition;
	btScalar _completionDistance;
	NezVoidBlock _moveNearMovementCompletionHandler;
	int _noMovementCount;
	
	btVector3 _currentThrusterForce;
	btVector3 _previousLinearVelocity;
	btScalar _previousLinearAccelertionX;
	btScalar _previousLinearAccelertionY;
	btScalar _previousLinearAccelertionZ;
	btVector3 _previousAngularVelocity;

	btScalar _massEstimate; // mass including containing object's masses
	CFTimeInterval _zStartupTime;
	CFTimeInterval _halfZStartupTime;
	
	NezDynamicStepAction _currentStepAction;
	
	NSMutableArray *_collisionsList;
}

-(instancetype)init {
	if ((self = [super init])) {
		_currentStepAction = NEZ_ACTION_DO_NOTHING;
		self.maximumLinearVelocity = GLKVector3Make(20.0, 20.0, 20.0);
		self.collisionMinBounce = GLKVector3Make(-2.0, -2.0, -2.0);
		self.collisionMaxBounce = GLKVector3Make(2.0, 2.0, 2.0);
		_collisionsList = [NSMutableArray array];
	}
	return self;
}

-(void)setRigidBody:(void*)rigidBody andCollisionShape:(void*)collisionShape {
	_rigidBody = (btRigidBody*)rigidBody;
	_collisionShape = (btCollisionShape*)collisionShape;
}

-(void*)rigidBody {
	return _rigidBody;
}

-(void*)collisionShape {
	return _collisionShape;
}

-(BOOL)rigidBodyIsActive {
	return _rigidBody->isActive();
}

-(BOOL)needStepSimulation {
	return _currentStepAction != NEZ_ACTION_DO_NOTHING;
}

-(float)maximumForce {
	return abs(_rigidBody->getGravity().z())*self.bodyMass*50;
}

-(float)maximumVelocity {
	return 25;
}

-(void)allocateDynamicObject {}

-(void)setRigidBodyTransform:(CATransform3D)transform {
	if (_rigidBody && _rigidBody->isKinematicObject()) {
		self.transform = transform;
		GLKTransform t = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(transform));
		_rigidBody->activate(true);
		_rigidBody->clearForces();
		_rigidBody->getMotionState()->setWorldTransform(btTransform(btQuat4(t.orientation), btVec3(t.position)));
	}
}

-(void)setRigidBodyPosition:(SCNVector3)position andRotation:(SCNVector4)rotation {
	if (_rigidBody && _rigidBody->isKinematicObject()) {
		btQuaternion orientation = btQuaternion(0,0,0,1);
		if (rotation.w != 0) {
			orientation.setRotation(btVector3(rotation.x, rotation.y, rotation.z), rotation.w);
		}
		btVector3 pos = btVector3(position.x, position.y, position.z);
		_rigidBody->activate(true);
		_rigidBody->clearForces();
		_rigidBody->getMotionState()->setWorldTransform(btTransform(orientation, pos));
	}
}

-(void)setRigidBodyOrientation:(GLKQuaternion)orientation {
	if (_rigidBody && _rigidBody->isKinematicObject()) {
		btVector3 pos = btVec3(self.position);
		_rigidBody->activate(true);
		_rigidBody->clearForces();
		_rigidBody->getMotionState()->setWorldTransform(btTransform(btQuat4(orientation), pos));
	}
}

-(void)setRigidBodyPosition:(GLKVector3)position andOrientation:(GLKQuaternion)orientation {
	if (_rigidBody && _rigidBody->isKinematicObject()) {
		btVector3 pos = btVec3(position);
		_rigidBody->activate(true);
		_rigidBody->clearForces();
		_rigidBody->getMotionState()->setWorldTransform(btTransform(btQuat4(orientation), pos));
	}
}

-(void)synchronizePosition {
	if (_rigidBody && !_isCoreAnimating) {
		btTransform trans;
		_rigidBody->getMotionState()->getWorldTransform(trans);
		btScalar matrix[16];
		trans.getOpenGLMatrix(matrix);
		CATransform3D transform = {
			matrix[ 0], matrix[ 1], matrix[ 2], matrix[ 3],
			matrix[ 4], matrix[ 5], matrix[ 6], matrix[ 7],
			matrix[ 8], matrix[ 9], matrix[10], matrix[11],
			matrix[12], matrix[13], matrix[14], matrix[15],
		};
		//probably smarter to convert the transform but I am adding everthing to the root node so no conversion is necessary
		self.transform = transform;//[self.parentNode convertTransform:transform fromNode:nil];
	}
}

-(void)setKinematic {
	_rigidBody->setCollisionFlags(_rigidBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
	_rigidBody->setActivationState(DISABLE_DEACTIVATION);
	_rigidBody->activate(true);
}

-(void)setDynamic {
	_rigidBody->setCollisionFlags(_rigidBody->getCollisionFlags() & (~btCollisionObject::CF_KINEMATIC_OBJECT));
	_rigidBody->forceActivationState(ACTIVE_TAG);
	_rigidBody->setDeactivationTime(0.0f);
	_rigidBody->setLinearVelocity(btVector3(0.0, 0.0, 0.0));
	_rigidBody->setAngularVelocity(btVector3(0.0, 0.0, 0.0));
	_rigidBody->clearForces();
}

-(void)stopMotion {
	_rigidBody->activate();
	_rigidBody->setLinearVelocity(btVector3(0.0, 0.0, 0.0));
	_rigidBody->setAngularVelocity(btVector3(0.0, 0.0, 0.0));
	_rigidBody->clearForces();
}

-(void)scaleLinearVelocity:(float)scaleFactor {
	_rigidBody->activate();
	_rigidBody->setLinearVelocity(_rigidBody->getLinearVelocity()*scaleFactor);
}

-(void)scaleAngularVelocity:(float)scaleFactor {
	_rigidBody->activate();
	_rigidBody->setAngularVelocity(_rigidBody->getAngularVelocity()*scaleFactor);
}

-(void)applyCentralImpulse:(SCNVector3)impulseVector {
	_rigidBody->activate();
	_rigidBody->applyCentralImpulse(btVec3(impulseVector));
}

-(void)applyImpulse:(SCNVector3)impulseVector atRelativePosition:(SCNVector3)position {
	_rigidBody->activate();
	_rigidBody->applyImpulse(btVec3(impulseVector), btVec3(position));
}

-(void)applyCentralForce:(SCNVector3)forceVector {
	_rigidBody->activate();
	_rigidBody->applyCentralForce(btVec3(forceVector));
}

-(void)applyForce:(SCNVector3)forceVector atRelativePosition:(SCNVector3)position {
	_rigidBody->activate();
	_rigidBody->applyForce(btVec3(forceVector), btVec3(position));
}

-(void)stepSimulationWithElapsedTime:(CFTimeInterval)elapsedTime {
	switch (_currentStepAction) {
		case NEZ_ACTION_HOVER:
			[self stepHoverSimulationWithElapsedTime:elapsedTime];
			break;
		case NEZ_ACTION_MOVE_NEAR:
			[self stepMoveNearSimulationWithElapsedTime:elapsedTime];
			break;
		default:
			break;
	}
	[self clearCollisions];
}

-(void)moveNearPosition:(SCNVector3)position withMovementCompletionHandler:(NezVoidBlock)movementCompletionHandler {
	[self moveNearPosition:position withZStartupTime:0.0 andMovementCompletionHandler:movementCompletionHandler];
}

-(void)moveNearPosition:(SCNVector3)position withZStartupTime:(CFTimeInterval)zStartupTime andMovementCompletionHandler:(NezVoidBlock)movementCompletionHandler {
	_moveToPosition = btVec3(position);
	_currentThrusterForce = btVector3(0.0, 0.0, 0.0);
	
	btTransform worldTrans;
	_rigidBody->getMotionState()->getWorldTransform(worldTrans);
	_previousLinearVelocity = _rigidBody->getLinearVelocity();
	_massEstimate = self.bodyMass; //These are different if something is on top of the object moving
	
	_zStartupTime = zStartupTime;
	_halfZStartupTime = zStartupTime*0.5;
	
	_moveNearMovementCompletionHandler = [movementCompletionHandler copy];
	
	_currentStepAction = NEZ_ACTION_MOVE_NEAR;
}

-(void)stopMoving {
	_currentStepAction = NEZ_ACTION_DO_NOTHING;
	_currentThrusterForce = btVector3(0.0, 0.0, 0.0);
}

-(void)stepMoveNearSimulationWithElapsedTime:(CFTimeInterval)elapsedTime {
}

-(void)stopHovering {
	_currentStepAction = NEZ_ACTION_DO_NOTHING;
	_currentThrusterForce = btVector3(0.0, 0.0, 0.0);
	_wantsOrientationToChange = NO;
}

-(void)hoverAtPosition:(GLKVector3)position andOrientation:(GLKQuaternion)orientation andCompletionHandler:(NezVoidBlock)completionHandler {
	[self hoverAtPosition:position andOrientation:orientation withZStartupTime:0.0 andCompletionHandler:completionHandler];
}

-(void)hoverAtPosition:(GLKVector3)position andOrientation:(GLKQuaternion)orientation withZStartupTime:(CFTimeInterval)zStartupTime andCompletionHandler:(NezVoidBlock)completionHandler {
	_hoverToOrientation = orientation;
	_wantsOrientationToChange = YES;
	[self hoverAtPosition:position withZStartupTime:zStartupTime andCompletionHandler:completionHandler];
}

-(void)hoverAtPosition:(GLKVector3)position andCompletionHandler:(NezVoidBlock)completionHandler {
	[self hoverAtPosition:position withZStartupTime:0.0 andCompletionHandler:completionHandler];
}

-(void)hoverAtPosition:(GLKVector3)position withZStartupTime:(CFTimeInterval)zStartupTime andCompletionHandler:(NezVoidBlock)completionHandler {
	[self hoverToNode:nil atOffset:position andRelativeOrientation:GLKQuaternionIdentity withZStartupTime:zStartupTime completionDistance:1.0 andCompletionHandler:completionHandler];
}

-(void)hoverToNode:(SCNNode*)node atOffset:(GLKVector3)position andRelativeOrientation:(GLKQuaternion)orientation withCompletionDistance:(float)distance completionTimeout:(float)timeout andCompletionHandler:(NezVoidBlock)completionHandler {
	[self hoverToNode:node atOffset:position andRelativeOrientation:orientation withZStartupTime:0.0 completionDistance:distance andCompletionHandler:completionHandler];
	_movementTimeout = timeout;
	_hasTimeout = YES;
}

-(void)hoverToNode:(SCNNode*)node atOffset:(GLKVector3)position andRelativeOrientation:(GLKQuaternion)orientation withZStartupTime:(CFTimeInterval)zStartupTime completionDistance:(float)distance andCompletionHandler:(NezVoidBlock)completionHandler {
	if (node) {
		_wantsOrientationToChange = YES;
		_relativeOrientation = orientation;
	}
	_hoverToNode = node;
	_hoverToOffset = btVec3(position);
	_completionDistance = distance;
	_currentThrusterForce = btVector3(0.0, 0.0, 0.0);
	
	_previousLinearVelocity = _rigidBody->getLinearVelocity();
	_previousAngularVelocity = _rigidBody->getAngularVelocity();
	_massEstimate = self.bodyMass; //These are different if something is on top of the object moving
	
	_zStartupTime = zStartupTime;
	_halfZStartupTime = zStartupTime*0.5;
	
	_hoverMovementCompletionHandler = [completionHandler copy];
	
	_currentStepAction = NEZ_ACTION_HOVER;
	
	_noMovementCount = 0;

	_previousLinearAccelertionX = 0.0;
	_previousLinearAccelertionY = 0.0;
	_previousLinearAccelertionZ = 0.0;
	
	_hasTimeout = NO;
}

-(void)stepHoverSimulationWithElapsedTime:(CFTimeInterval)elapsedTime {
	btVector3 lv = _rigidBody->getLinearVelocity();
	
	btTransform worldTrans;
	_rigidBody->getMotionState()->getWorldTransform(worldTrans);
	btVector3 pos = worldTrans.getOrigin();
	btVector3 hoverPos = _hoverToOffset;
	
	if (_hoverToNode) {
		hoverPos = btVec3([_hoverToNode convertPosition:SCNVector3Make(_hoverToOffset.x(), _hoverToOffset.y(), _hoverToOffset.z()) toNode:nil]);
		_hoverToOrientation = GLKQuaternionMakeWithMatrix4(GLKMatrix4FromCATransform3D(_hoverToNode.transform));
		_hoverToOrientation = GLKQuaternionMultiply(_hoverToOrientation, _relativeOrientation);
	}
	btVector3 diff = hoverPos-pos;
	btVector3 gravity = _rigidBody->getGravity();
	
	btScalar forceX = _currentThrusterForce.x();
	btScalar forceY = _currentThrusterForce.y();
	btScalar forceZ = _currentThrusterForce.z();
	
	btScalar aZ = (lv.z()-_previousLinearVelocity.z())/(elapsedTime);
	
	if (forceZ != 0.0 && aZ != 0.0) {
		_massEstimate = (forceZ)/(aZ-gravity.z());
	}
	if (_massEstimate < self.bodyMass) {
		_massEstimate = self.bodyMass;
	}
	
	if (_zStartupTime <= 0) {
		[self getForce:&forceX andAcceleration:&_previousLinearAccelertionX forDistance:diff.x() accelerationDueToGravity:gravity.x() currentVelocity:lv.x() maximumVelocity:self.maximumLinearVelocity.x andTimeDelta:elapsedTime];
		[self getForce:&forceY andAcceleration:&_previousLinearAccelertionY forDistance:diff.y() accelerationDueToGravity:gravity.y() currentVelocity:lv.y() maximumVelocity:self.maximumLinearVelocity.y andTimeDelta:elapsedTime];
		[self getForce:&forceZ andAcceleration:&_previousLinearAccelertionZ forDistance:diff.z() accelerationDueToGravity:gravity.z() currentVelocity:lv.z() maximumVelocity:self.maximumLinearVelocity.z andTimeDelta:elapsedTime];
		
		if (_wantsOrientationToChange) {
			btQuaternion o2 = btQuaternion(_hoverToOrientation.x, _hoverToOrientation.y, _hoverToOrientation.z, _hoverToOrientation.w);
			
			btTransform iwt = worldTrans;
			iwt.setRotation(o2);
			
			btVector3 lv, av;
			btTransformUtil::calculateVelocity(worldTrans, iwt, elapsedTime, lv, av);
			
			av *= 0.03;
			btVector3 dav = (av-_previousAngularVelocity);
			av = _previousAngularVelocity+(dav*0.05);
			
			if (self.collisionCount == 0) {
				_rigidBody->setAngularVelocity(av);
			}
		}
	} else {
		_zStartupTime -= elapsedTime;
		if (_zStartupTime < _halfZStartupTime) {
			[self getForce:&forceX andAcceleration:&_previousLinearAccelertionX forDistance:diff.x() accelerationDueToGravity:gravity.x() currentVelocity:lv.x() maximumVelocity:self.maximumLinearVelocity.x andTimeDelta:elapsedTime];
			[self getForce:&forceY andAcceleration:&_previousLinearAccelertionY forDistance:diff.y() accelerationDueToGravity:gravity.y() currentVelocity:lv.y() maximumVelocity:self.maximumLinearVelocity.y andTimeDelta:elapsedTime];
		}
		[self getForce:&forceZ andAcceleration:&_previousLinearAccelertionZ forDistance:diff.z() accelerationDueToGravity:gravity.z() currentVelocity:lv.z() maximumVelocity:self.maximumLinearVelocity.z andTimeDelta:elapsedTime];
	}
	_previousAngularVelocity = _rigidBody->getAngularVelocity();
	
	_currentThrusterForce = btVector3(forceX, forceY, forceZ);
	
	_rigidBody->activate();
	_rigidBody->applyCentralForce(_currentThrusterForce);
	
	_previousLinearVelocity = lv;

	if (self.collisionCount > 0) {
		btVector3 impulseVector = btVector3(randomFloatBetween(_collisionMinBounce.x, _collisionMaxBounce.x), randomFloatBetween(_collisionMinBounce.y, _collisionMaxBounce.y), randomFloatBetween(_collisionMinBounce.z, _collisionMaxBounce.z));
		_rigidBody->applyCentralImpulse(impulseVector);
		btScalar torque = GLKVector3Length(GLKVector3Subtract(_collisionMaxBounce, _collisionMinBounce))*self.bodyMass;
		_rigidBody->applyTorqueImpulse(btVector3(randomFloatInRange(-torque, 2.0*torque), randomFloatInRange(-torque, 2.0*torque), randomFloatInRange(-torque, 2.0*torque)));
	}
	if (_hasTimeout) {
		_movementTimeout -= elapsedTime;
	}
	NezVoidBlock completionHandler = _hoverMovementCompletionHandler;
	if (completionHandler && ((diff.length() <= _completionDistance) || (_hasTimeout && _movementTimeout <= 0.0))) {
		_hoverMovementCompletionHandler = nil;
		completionHandler();
	}
}

-(void)getForce:(btScalar*)force andAcceleration:(btScalar*)acceleration forDistance:(btScalar)distance accelerationDueToGravity:(btScalar)g currentVelocity:(btScalar)currentVelocity maximumVelocity:(btScalar)maximumVelocity andTimeDelta:(btScalar)dt {
	btScalar ca = *acceleration;
	btScalar maximumForce = self.maximumForce;
	btScalar velocityDistance = fabs(distance);
	btScalar preferredLinearVelocity = maximumVelocity;
	
	if (distance > 0.0) {
		preferredLinearVelocity = (velocityDistance > maximumVelocity)?maximumVelocity:velocityDistance;
	} else {
		preferredLinearVelocity = (velocityDistance > maximumVelocity)?-maximumVelocity:-velocityDistance;
	}
	btScalar dv = (preferredLinearVelocity-currentVelocity)*0.05;
	btScalar a = (dv)/(dt);
	btScalar da = a-ca;
	if (da > 2.5) {
		da = 2.5;
	} else if (da < -2.5) {
		da = -2.5;
	}
	a = ca+da;
	btScalar f = _massEstimate*(a-(g));
	if (f > maximumForce) {
		f = maximumForce;
	} else if (f < -maximumForce) {
		f = -maximumForce;
	}
	*acceleration = a;
	*force = f;
}

-(void)addCollisionNode:(NezDynamicNode*)collisionNode {
	[_collisionsList addObject:collisionNode];
}

-(void)clearCollisions {
	[_collisionsList removeAllObjects];
}

-(NSUInteger)collisionCount {
	return _collisionsList.count;
}

-(void)dealloc {
	if (_rigidBody) {
		delete _rigidBody->getMotionState();
		delete _rigidBody;
	}
	if (_collisionShape) {
		delete _collisionShape;
	}
}

@end
