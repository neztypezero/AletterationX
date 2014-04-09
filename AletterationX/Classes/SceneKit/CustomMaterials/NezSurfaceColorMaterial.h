//
//  NezSurfaceColorMaterial.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface NezSurfaceColorMaterial : SCNMaterial

@property SCNVector3 mu_SurfaceColor;
@property SCNVector3 mu_DiffuseTintColor;

+(instancetype)materialWithShaderPath:(NSString*)path;

@end
