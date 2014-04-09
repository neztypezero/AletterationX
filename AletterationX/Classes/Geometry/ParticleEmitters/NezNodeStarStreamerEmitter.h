//
//  NezNodeStarStreamerEmitter.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/19.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNodeParticleEmitter.h"

@interface NezNodeStarStreamerEmitter : NezNodeParticleEmitter

-(void)setupStreamerWithTexture:(GLuint)texture ColorRamp:(GLuint)colorRamp andCompletionHandler:(NezVoidBlock)completionHandler;

@end
