//
//  NezDynamicNode.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/11.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"

@interface NezDynamicNode : NezNode 

@property (readonly, getter = needStepSimulation) BOOL needStepSimulation;

@property (readonly, getter = maximumForce) float maximumForce;
@property (readonly, getter = maximumVelocity) float maximumVelocity;
@property (readonly, getter = rigidBody) void* rigidBody;
@property (readonly, getter = collisionShape) void* collisionShape;
@property (readonly, getter = rigidBodyIsActive) BOOL rigidBodyIsActive;
@property GLKVector3 maximumLinearVelocity;
@property BOOL isCoreAnimating;

@property (readonly, getter = collisionCount) NSUInteger collisionCount;

@property float bodyMass;
@property float restitution;
@property float friction;
@property float angularDamping;
@property float linearDamping;
@property GLKVector3 collisionMinBounce;
@property GLKVector3 collisionMaxBounce;

-(void)allocateDynamicObject;
-(void)synchronizePosition;

-(void)applyCentralImpulse:(SCNVector3)impulseVector;
-(void)applyImpulse:(SCNVector3)impulseVector atRelativePosition:(SCNVector3)position;
-(void)applyCentralForce:(SCNVector3)forceVector;
-(void)applyForce:(SCNVector3)forceVector atRelativePosition:(SCNVector3)position;

-(void)setKinematic;
-(void)setDynamic;
-(void)setRigidBodyTransform:(CATransform3D)transform;
-(void)setRigidBodyPosition:(SCNVector3)position andRotation:(SCNVector4)rotation;
-(void)setRigidBodyOrientation:(GLKQuaternion)q;
-(void)setRigidBodyPosition:(GLKVector3)position andOrientation:(GLKQuaternion)q;

-(void)stopMotion;
-(void)scaleLinearVelocity:(float)scaleFactor;
-(void)scaleAngularVelocity:(float)scaleFactor;

-(void)moveNearPosition:(SCNVector3)position withMovementCompletionHandler:(NezVoidBlock)movementCompletionHandler;
-(void)moveNearPosition:(SCNVector3)position withZStartupTime:(CFTimeInterval)zStartupTime andMovementCompletionHandler:(NezVoidBlock)movementCompletionHandler;

-(void)hoverAtPosition:(GLKVector3)position andCompletionHandler:(NezVoidBlock)completionHandler;
-(void)hoverAtPosition:(GLKVector3)position withZStartupTime:(CFTimeInterval)zStartupTime andCompletionHandler:(NezVoidBlock)completionHandler ;
-(void)hoverAtPosition:(GLKVector3)position andOrientation:(GLKQuaternion)orientation andCompletionHandler:(NezVoidBlock)completionHandler;
-(void)hoverAtPosition:(GLKVector3)position andOrientation:(GLKQuaternion)orientation withZStartupTime:(CFTimeInterval)zStartupTime andCompletionHandler:(NezVoidBlock)completionHandler;
-(void)hoverToNode:(SCNNode*)node atOffset:(GLKVector3)position andRelativeOrientation:(GLKQuaternion)orientation withZStartupTime:(CFTimeInterval)zStartupTime completionDistance:(float)distance andCompletionHandler:(NezVoidBlock)completionHandler;
-(void)hoverToNode:(SCNNode*)node atOffset:(GLKVector3)position andRelativeOrientation:(GLKQuaternion)orientation withCompletionDistance:(float)distance completionTimeout:(float)timeout andCompletionHandler:(NezVoidBlock)completionHandler;
-(void)stopHovering;
-(void)stepSimulationWithElapsedTime:(CFTimeInterval)elapsedTime;

-(void)addCollisionNode:(NezDynamicNode*)collisionNode;
-(void)clearCollisions;

-(void)setRigidBody:(void*)rigidBody andCollisionShape:(void*)collisionShape;

@end
