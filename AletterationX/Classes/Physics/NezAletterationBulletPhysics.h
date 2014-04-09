//
//  NezAletterationBulletPhysics.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/10.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@class NezDynamicNode;

typedef void (^ NezForceCompletionHandler)(NezDynamicNode *node);

@interface NezAletterationBulletPhysics : NSObject

@property (readonly, getter = dynamicsQueue) dispatch_queue_t dynamicsQueue;

+(instancetype)physicsWithDynamicNodeList:(NSArray*)dynamicNodeList;
-(instancetype)initWithDynamicNodeList:(NSArray*)dynamicNodeList;

-(void)addDynamicObjects:(NSArray*)objectList;

-(void)stepSimulationWithElapsedTime:(CFTimeInterval)elapsedTime;

-(void)addNoMoveConstraintForNode:(NezDynamicNode*)node withKey:(NSString*)key;
-(void)addConstraintStickNodeA:(NezDynamicNode*)nodeA toNodeB:(NezDynamicNode*)nodeB withKey:(NSString*)key;
-(void)addConstraintForNode:(NezDynamicNode*)node withKey:(NSString*)key;
-(void)removeConstraintForKey:(NSString*)key;

@end
