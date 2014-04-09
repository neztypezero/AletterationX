//
//  NezAletterationLetterBlock.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/08.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezDynamicNode.h"
#import "NezSurfaceColorMaterial.h"

#define getLuma(color) (((color.x * 299.0) + (color.y * 587.0) + (color.z * 114.0)) / 1000.0)

@interface NezAletterationLetterBlock : NezDynamicNode

@property (nonatomic, setter = setLetter:) char letter;
@property (nonatomic, setter = setIsLowerCase:) BOOL isLowerCase;
@property (strong) NezSurfaceColorMaterial *frontMaterial;
@property NSInteger boxRowIndex;
@property NSInteger boxColumnIndex;
@property NSInteger stackIndex;

+(instancetype)blockWithLetter:(char)letter andFrontMaterial:(NezSurfaceColorMaterial*)frontMaterial;
-(instancetype)initWithLetter:(char)letter andFrontMaterial:(NezSurfaceColorMaterial*)frontMaterial;

-(void)addAnimatingHighlight;
-(void)removeAnimatingHighlight;

@end
