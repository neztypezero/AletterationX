//
//  NezNodeFireworksEmitter.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/17.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezNodeParticleEmitter.h"
#import "OpenGL/gltypes.h"

@interface NezNodeFireworksEmitter : NezNodeParticleEmitter

-(void)setupFireworksWithTexture:(GLuint)texture ColorRamp:(GLuint)colorRamp andCompletionHandler:(NezVoidBlock)completionHandler;

@end
