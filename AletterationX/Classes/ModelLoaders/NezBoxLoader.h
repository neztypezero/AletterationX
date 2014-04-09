//
//  NezBoxLoader.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/16.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezSimpleObjLoader.h"

@interface NezBoxLoader : NezSimpleObjLoader

+(instancetype)boxWithWidth:(float)width Height:(float)height Depth:(float)depth SideThickness:(float)sideThickness BottomThickness:(float)thickness;
+(instancetype)lidWithWidth:(float)width Height:(float)height Depth:(float)depth SideThickness:(float)sideThickness TopThickness:(float)thickness;

-(instancetype)initWithWidth:(float)width Height:(float)height Depth:(float)depth SideThickness:(float)sideThickness Thickness:(float)thickness IsLid:(BOOL)isLid;

@end
