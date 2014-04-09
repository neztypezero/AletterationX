//
//  NezAletterationGraphics.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/09.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationGeometry.h"
#import "NezAletterationGameState.h"

#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_NONE 0
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_FLOOR 1
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_STACK_LABEL 5
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_WORD_LINE 10
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_RETIRED_WORDBOARD 11
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_RETIRED_WORD 12
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_LETTER_BLOCK 20
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_SMALL_BOX 30
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_SMALL_LID 31
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_BIG_BOX 40
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_BIG_LID 41
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE 50
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_TEXT 51
#define NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_PARTICLES 1000

@class NezAletterationGameTable;
@class NezNodeStarStreamerEmitter;

@interface NezAletterationGraphics : NSObject

@property (readonly) NSOpenGLContext *openGLContext;

@property (readonly, getter = scene) SCNScene *scene;
@property (readonly, getter = spotLightNode) SCNNode *spotLightNode;
@property (readonly, getter = dynamicNodeList) NSArray *dynamicNodeList;

@property (readonly) NezAletterationGameTable *gameTable;

+(instancetype)graphicsWithContext:(NSOpenGLContext*)ctx;
-(instancetype)initWithContext:(NSOpenGLContext*)ctx;

+(SCNVector3)letterBlockSize;
+(SCNVector3)wordLineSize;

+(NSString*)resourcePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir;
+(NSString*)resourceTexturePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir;
+(NSString*)resourceShaderModiferPathWithFilename:(NSString*)filename;

+(SCNMaterial*)colorMaterial:(NSColor*)color;
+(void)setupMaterial:(SCNMaterial*)material withTexturePath:(NSString*)texturePath;
+(SCNMaterial*)textureMaterial:(NSString*)texturePath;

+(NezAletterationBox*)newBigLid;
+(NezAletterationBigBox*)newBigBox;
+(NezAletterationGameBoard*)newGameBoard;
+(NezAletterationBox*)newSmallBox;
+(NezAletterationBox*)newSmallLid;
+(NezAletterationWordLine*)newWordLine;
+(NSArray*)newLetterBlockList;

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)elapsedTime;

-(void)addFireworksEmitterAt:(SCNVector3)position withEmitterNode:(SCNNode*)emitterNode;
-(NezNodeStarStreamerEmitter*)addStarStreamEmitterAt:(SCNVector3)position withEmitterNode:(SCNNode*)emitterNode;

@end
