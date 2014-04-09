//
//  NezAletterationGraphics.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/09.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationGraphics.h"
#import "NezAletterationGameTable.h"
#import "NezAletterationGameState.h"
#import "NezSimpleObjLoader.h"
#import "NezAletterationGeometry.h"
#import "NezRandom.h"
#import "NezSCNMaterials.h"
#import "NezNodeFireworksEmitter.h"
#import "NezNodeStarStreamerEmitter.h"

#define NEZ_ALETTERATION_GRAPHICS_LETTER_BLOCK_DEPTH 0.5
#define NEZ_ALETTERATION_GRAPHICS_LETTER_BLOCK_SIZE_RATIO 6.8

#define NEZ_ALETTERATION_GRAPHICS_FRICTION_BIG_BOX 0.95
#define NEZ_ALETTERATION_GRAPHICS_FRICTION_BIG_LID 0.95
#define NEZ_ALETTERATION_GRAPHICS_FRICTION_SMALL_BOX 0.95
#define NEZ_ALETTERATION_GRAPHICS_FRICTION_SMALL_LID 0.95
#define NEZ_ALETTERATION_GRAPHICS_FRICTION_LETTER_BLOCK 0.95

#define NEZ_ALETTERATION_GRAPHICS_RESTITUTION_BIG_BOX 0.15
#define NEZ_ALETTERATION_GRAPHICS_RESTITUTION_BIG_LID 0.15
#define NEZ_ALETTERATION_GRAPHICS_RESTITUTION_SMALL_BOX 0.15
#define NEZ_ALETTERATION_GRAPHICS_RESTITUTION_SMALL_LID 0.15
#define NEZ_ALETTERATION_GRAPHICS_RESTITUTION_LETTER_BLOCK 0.25

#define NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_BIG_BOX 0.5
#define NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_BIG_LID 0.5
#define NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_SMALL_BOX 0.25
#define NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_SMALL_LID 0.25
#define NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_LETTER_BLOCK 0.35

#define NEZ_ALETTERATION_GRAPHICS_BODY_MASS_BIG_BOX 50
#define NEZ_ALETTERATION_GRAPHICS_BODY_MASS_BIG_LID 50
#define NEZ_ALETTERATION_GRAPHICS_BODY_MASS_SMALL_BOX 20
#define NEZ_ALETTERATION_GRAPHICS_BODY_MASS_SMALL_LID 20
#define NEZ_ALETTERATION_GRAPHICS_BODY_MASS_LETTER_BLOCK 0.5

#define NEZ_ALETTERATION_GRAPHICS_SMALL_LID_THICKNESS_RATIO 0.20
#define NEZ_ALETTERATION_GRAPHICS_SMALL_LID_SIDE_THICKNESS_RATIO 0.05
#define NEZ_ALETTERATION_GRAPHICS_SMALL_BOX_THICKNESS_RATIO 0.2
#define NEZ_ALETTERATION_GRAPHICS_SMALL_BOX_SIDE_THICKNESS_RATIO 0.075

#define NEZ_ALETTERATION_GRAPHICS_BIG_LID_THICKNESS_RATIO 0.2
#define NEZ_ALETTERATION_GRAPHICS_BIG_LID_SIDE_THICKNESS_RATIO 0.0125
#define NEZ_ALETTERATION_GRAPHICS_BIG_BOX_THICKNESS_RATIO 0.2
#define NEZ_ALETTERATION_GRAPHICS_BIG_BOX_SIDE_THICKNESS_RATIO 0.0125

#define NEZ_ALETTERATION_GRAPHICS_SCALE_FACTOR (4.0)

@interface Vector3Object : NSObject

@property GLKVector3 vec3;

@end

@implementation Vector3Object

-(BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[Vector3Object class]]) {
		Vector3Object *v = object;
		return (v.vec3.x == self.vec3.x && v.vec3.y == self.vec3.y && v.vec3.z == self.vec3.z);
	} else {
		return NO;
	}
}

@end

typedef struct BoxSize {
	float lidW, lidH, lidD;
	float lidTopThickness, lidSideThickness;
	float boxW, boxH, boxD;
	float boxBottomThickness, boxSideThickness;
} BoxSize;

typedef struct VertexIndex {
	unsigned long v, t, n;
} VertexIndex;

typedef struct TriangleIndex {
	VertexIndex v0, v1, v2;
} TriangleIndex;

BoxSize gSmallBoxSize = {
	18.199293, 13.243001, 3.786606,
	0.757321, 0.544000,
	16.924294, 11.968000, 4.896000,
	0.816000, 0.544000,
};

BoxSize gBigBoxSize = {
	32.727081, 45.591721, 8.571379,
	1.714276, 0.534604,
	30.972912, 43.837547, 8.819181,
	3.054077, 0.534604,
};

SCNGeometry *gBigBoxGeometry;
SCNGeometry *gBigBoxLidGeometry;

SCNGeometry *gLetterBoxGeometry;
SCNGeometry *gLetterBoxLidGeometry;

SCNVector3 gLetterBlockDimensions;
SCNGeometry *gLetterBlockGeometry;
SCNGeometry *gWordLineGeometry;
SCNVector3 gWordLineDimensions;

NSMutableDictionary *gParticleTexureInfoDictionary;

@implementation NezAletterationGraphics {
	SCNScene *_scene;
	
	NSMutableArray *_dynamicNodeList;

	SCNNode *_spotLightNode;
	
	NSMutableArray *_emitterList;
}

+(SCNVector3)letterBlockSize {
	return gLetterBlockDimensions;
}

+(SCNVector3)wordLineSize {
	return gWordLineDimensions;
}

+(void)initializeWithContext:(NSOpenGLContext*)openGLContext {
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		gBigBoxGeometry = [NezAletterationGraphics loadGeometryFromSceneWithName:@"BigBoxBevel" andNodeName:@"BigBox"];
		gBigBoxLidGeometry = [NezAletterationGraphics loadGeometryFromSceneWithName:@"BigBoxLidBevel" andNodeName:@"BigBoxLid"];
		
		gLetterBoxGeometry = [NezAletterationGraphics loadGeometryFromSceneWithName:@"SmallBoxBevel" andNodeName:@"SmallBox"];
		gLetterBoxLidGeometry = [NezAletterationGraphics loadGeometryFromSceneWithName:@"SmallBoxLidBevel" andNodeName:@"SmallBoxLid"];
		
		gLetterBlockGeometry = [NezAletterationGraphics loadGeometryFromSceneWithName:@"LetterBlock" andNodeName:@"LetterBlock"];
		
		SCNVector3 min, max;
		[gLetterBlockGeometry getBoundingBoxMin:&min max:&max];
		gLetterBlockDimensions = SCNVector3Make(max.x-min.x, max.y-min.y, max.z-min.z);
		
		gWordLineGeometry = [SCNPlane planeWithWidth:gLetterBlockDimensions.x*20.0 height:gLetterBlockDimensions.y];
		[gWordLineGeometry getBoundingBoxMin:&min max:&max];
		gWordLineDimensions = SCNVector3Make(max.x-min.x, max.y-min.y, max.z-min.z);
		
		gParticleTexureInfoDictionary = [NSMutableDictionary dictionary];
		
		for (NSString *path in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Textures/Particles/"]) {
			NSString *file = [path.lastPathComponent stringByDeletingPathExtension];
			NSError *error;
			
			@try {
				GLKTextureInfo *texInfo = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&error];
				gParticleTexureInfoDictionary[file] = texInfo;
			} @catch (NSException *exception) {
				NSLog(@"%@", exception);
			}
		}
	});
}

+(GLuint)particleTextureForName:(NSString*)name {
	GLKTextureInfo *tex = gParticleTexureInfoDictionary[name];
	if (tex) {
		return tex.name;
	}
	return 0;
}

+(SCNGeometry*)loadGeometryWithVertexArray:(NezModelVertexArray*)vertexArray {
	// create the geometry source
	SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:vertexArray.vertexData
																							 semantic:SCNGeometrySourceSemanticVertex
																						 vectorCount:vertexArray.vertexCount
																					floatComponents:YES
																			  componentsPerVector:3
																				 bytesPerComponent:sizeof(float)
																						  dataOffset:0
																						  dataStride:sizeof(NezModelVertex)];
	
	// create the normal source
	SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:vertexArray.vertexData
																							 semantic:SCNGeometrySourceSemanticNormal
																						 vectorCount:vertexArray.vertexCount
																					floatComponents:YES
																			  componentsPerVector:3
																				 bytesPerComponent:sizeof(float)
																						  dataOffset:offsetof(NezModelVertex, normal)
																						  dataStride:sizeof(NezModelVertex)];
	
	
	// create the texcoord source
	SCNGeometrySource *texCoordSource = [SCNGeometrySource geometrySourceWithData:vertexArray.vertexData
																								semantic:SCNGeometrySourceSemanticTexcoord
																							vectorCount:vertexArray.vertexCount
																					  floatComponents:YES
																				 componentsPerVector:2
																					bytesPerComponent:sizeof(float)
																							 dataOffset:offsetof(NezModelVertex, uv)
																							 dataStride:sizeof(NezModelVertex)];
	
	
	// create the geometry element
	SCNGeometryElement *elementSource = [SCNGeometryElement geometryElementWithData:vertexArray.indexData
																							primitiveType:SCNGeometryPrimitiveTypeTriangles
																						  primitiveCount:vertexArray.indexCount
																							bytesPerIndex:sizeof(unsigned short)];
	
	// return the geometry
	return [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texCoordSource] elements:@[elementSource]];
}

+(SCNGeometry*)loadGeometryFromSceneWithName:(NSString*)sceneName andNodeName:(NSString*)nodeName {
	NSError *error = nil;
	NSString *path = [NezAletterationGraphics resourcePathWithFilename:sceneName Type:@"dae" Dir:@"Models"];
	SCNScene *scene = [SCNScene sceneWithURL:[NSURL fileURLWithPath:path] options:nil error:&error];
	if (!error && scene) {
		SCNNode *node = [scene.rootNode childNodeWithName:nodeName recursively:YES];
		if (node && node.geometry) {
			return [node.geometry copy];
		}
	}
	return nil;
}

+(NSString*)resourcePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir {
	return [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
}

+(NSString*)resourceTexturePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir {
	return [self resourcePathWithFilename:filename Type:fileType Dir:[NSString stringWithFormat:@"Textures/%@", dir]];
}

+(NSString*)resourceShaderModiferPathWithFilename:(NSString*)filename {
	return [self resourcePathWithFilename:filename Type:@"shader" Dir:@"ShaderModifiers"];
}

+(instancetype)graphicsWithContext:(NSOpenGLContext*)ctx {
	return [[NezAletterationGraphics alloc] initWithContext:ctx];
}

-(instancetype)initWithContext:(NSOpenGLContext*)ctx {
	if ((self = [super init])) {
		[NezAletterationGraphics initializeWithContext:ctx];

//		TriangleIndex t[28] = {
//			{{ 1},{ 2},{ 3}},
//			{{ 4},{ 1},{ 5}},
//			{{ 6},{ 4},{ 7}},
//			{{ 2},{ 6},{ 8}},
//			{{ 4},{ 6},{ 2}},
//			{{ 9},{10},{11}},
//			{{12},{13},{ 5}},
//			{{14},{12},{ 3}},
//			{{15},{14},{ 8}},
//			{{13},{15},{ 7}},
//			{{16},{11},{13}},
//			{{ 9},{16},{12}},
//			{{10},{ 9},{14}},
//			{{11},{10},{15}},
//			{{ 5},{ 1},{ 3}},
//			{{ 7},{ 4},{ 5}},
//			{{ 8},{ 6},{ 7}},
//			{{ 3},{ 2},{ 8}},
//			{{ 1},{ 4},{ 2}},
//			{{16},{ 9},{11}},
//			{{ 3},{12},{ 5}},
//			{{ 8},{14},{ 3}},
//			{{ 7},{15},{ 8}},
//			{{ 5},{13},{ 7}},
//			{{12},{16},{13}},
//			{{14},{ 9},{12}},
//			{{15},{10},{14}},
//			{{13},{11},{15}},
//		};
//		float blockDepth = NEZ_ALETTERATION_GRAPHICS_LETTER_BLOCK_DEPTH;
//		float blockSize = blockDepth*NEZ_ALETTERATION_GRAPHICS_LETTER_BLOCK_SIZE_RATIO;
//		
//		BoxSize smallBox = writeBox(@"SmallBox", t, blockSize*3.2, 1.37425742574258, 0.20806335493161, blockSize*1.20, NEZ_ALETTERATION_GRAPHICS_SMALL_LID_SIDE_THICKNESS_RATIO, NEZ_ALETTERATION_GRAPHICS_SMALL_LID_THICKNESS_RATIO);
//		BoxSize bigBox = writeBox(@"BigBox",   t, smallBox.lidW*2.35, 0.71782945736434, 0.26190476190476, (smallBox.lidTopThickness+smallBox.boxD)*1.30, NEZ_ALETTERATION_GRAPHICS_BIG_LID_SIDE_THICKNESS_RATIO,   NEZ_ALETTERATION_GRAPHICS_BIG_LID_THICKNESS_RATIO);
//		writeLetterBlock(blockSize, blockDepth);
//
//		printf("SmallBox = {\n");
//		printf("\t%f, %f, %f,\n", smallBox.lidW, smallBox.lidH, smallBox.lidD);
//		printf("\t%f, %f,\n", smallBox.lidTopThickness, smallBox.lidSideThickness);
//		printf("\t%f, %f, %f,\n", smallBox.boxW, smallBox.boxH, smallBox.boxD);
//		printf("\t%f, %f,\n", smallBox.boxBottomThickness, smallBox.boxSideThickness);
//		printf("};\n");
//		printf("BigBox = {\n");
//		printf("\t%f, %f, %f,\n", bigBox.lidW, bigBox.lidH, bigBox.lidD);
//		printf("\t%f, %f,\n", bigBox.lidTopThickness, bigBox.lidSideThickness);
//		printf("\t%f, %f, %f,\n", bigBox.boxW, bigBox.boxH, bigBox.boxD);
//		printf("\t%f, %f,\n", bigBox.boxBottomThickness, bigBox.boxSideThickness);
//		printf("};\n");
		
		_openGLContext = ctx;
		
		_emitterList = [NSMutableArray array];
		
		_scene = [SCNScene scene];
		
		// Create ambient light
		SCNLight *ambientLight = [SCNLight light];
		SCNNode *ambientLightNode = [SCNNode node];
		ambientLight.type = SCNLightTypeAmbient;
		ambientLight.color = [NSColor colorWithDeviceWhite:0.5 alpha:1.0];
		ambientLightNode.light = ambientLight;
		[_scene.rootNode addChildNode:ambientLightNode];
		
		// Create a spot light
		SCNLight *spotLight = [SCNLight light];
		spotLight.type = SCNLightTypeSpot;
//		spotLight.castsShadow = YES;
//		spotLight.shadowColor = [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.35];
//		spotLight.shadowRadius = 3.0;
//		[spotLight setAttribute:@10 forKey:SCNLightShadowNearClippingKey];
//		[spotLight setAttribute:@26 forKey:SCNLightShadowFarClippingKey];
		[spotLight setAttribute:@0 forKey:SCNLightSpotInnerAngleKey];
		[spotLight setAttribute:@140 forKey:SCNLightSpotOuterAngleKey];

		SCNNode *spotLightNode = [SCNNode node];
		spotLightNode.light = spotLight;
		spotLightNode.position = SCNVector3Make(20*NEZ_ALETTERATION_GRAPHICS_SCALE_FACTOR, 20*NEZ_ALETTERATION_GRAPHICS_SCALE_FACTOR, 25*NEZ_ALETTERATION_GRAPHICS_SCALE_FACTOR);
		
		_spotLightNode = spotLightNode;
		[_scene.rootNode addChildNode:spotLightNode];
		[spotLightNode setConstraints:@[[SCNLookAtConstraint lookAtConstraintWithTarget:_scene.rootNode]]];

		SCNMaterial *floorMaterial = [SCNMaterial material];
		floorMaterial.diffuse.contents = @"/Library/Desktop Pictures/Circles.jpg";
		floorMaterial.diffuse.contentsTransform = CATransform3DScale(CATransform3DMakeRotation(M_PI / 4, 0, 0, 1), 2.5/NEZ_ALETTERATION_GRAPHICS_SCALE_FACTOR, 2.5/NEZ_ALETTERATION_GRAPHICS_SCALE_FACTOR, 1.0);
		floorMaterial.diffuse.mipFilter = SCNLinearFiltering; //we also wan't to preload mipmaps
		floorMaterial.specular.wrapS = SCNWrapModeMirror;
		floorMaterial.specular.wrapT = SCNWrapModeMirror;
		floorMaterial.diffuse.wrapS  = SCNWrapModeMirror;
		floorMaterial.diffuse.wrapT  = SCNWrapModeMirror;
		floorMaterial.writesToDepthBuffer = YES;
		floorMaterial.readsFromDepthBuffer = NO;
		
		SCNFloor *floor = [SCNFloor floor];
		floor.firstMaterial = floorMaterial;
		
		SCNNode *floorNode = [SCNNode node];
		floorNode.geometry = floor;
		floorNode.transform = CATransform3DMakeRotation(M_PI/2.0, 1, 0, 0);
		floorNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_FLOOR;
		[_scene.rootNode addChildNode:floorNode];
		
		_gameTable = [NezAletterationGameTable table];
		
		[_scene.rootNode addChildNode:_gameTable.box];
		[_scene.rootNode addChildNode:_gameTable.lid];
		
		for (NezAletterationPlayer *player in _gameTable.playerList) {
			[_scene.rootNode addChildNode:player.gameBoard];
			[_scene.rootNode addChildNode:player.gameBoard.box];
			[_scene.rootNode addChildNode:player.gameBoard.lid];
			
			for (NezAletterationLetterBlock *letterBlock in player.gameBoard.letterBlockList) {
				[_scene.rootNode addChildNode:letterBlock];
			}
		}

		_dynamicNodeList = [NSMutableArray array];

		[_dynamicNodeList addObject:_gameTable.box];
		[_dynamicNodeList addObject:_gameTable.lid];
		
		for (NezAletterationPlayer *player in _gameTable.playerList) {
			[_dynamicNodeList addObject:player.gameBoard.box];
			[_dynamicNodeList addObject:player.gameBoard.lid];
			
			for (NezAletterationLetterBlock *letterBlock in player.gameBoard.letterBlockList) {
				[_dynamicNodeList addObject:letterBlock];
			}
		}
		
		for (NezDynamicNode *dynamicNode in _dynamicNodeList) {
			[dynamicNode allocateDynamicObject];
		}
	}
	return self;
}

-(NezNodeFireworksEmitter*)firstUnusedFireworksEmitter {
	for (NezNodeParticleEmitter *emitter in _emitterList) {
		if (!emitter.hasStarted && [emitter isKindOfClass:[NezNodeFireworksEmitter class]]) {
			return (NezNodeFireworksEmitter*)emitter;
		}
	}
	return nil;
}

-(NezNodeStarStreamerEmitter*)firstUnusedStarStreamEmitter {
	for (NezNodeParticleEmitter *emitter in _emitterList) {
		if (!emitter.hasStarted && [emitter isKindOfClass:[NezNodeStarStreamerEmitter class]]) {
			return (NezNodeStarStreamerEmitter*)emitter;
		}
	}
	return nil;
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)elapsedTime {
	[NezGCD dispatchBlock:^{
		for (NezNodeFireworksEmitter *emitter in _emitterList) {
			if (emitter.hasStarted) {
				[emitter updateWithTimeSinceLastUpdate:elapsedTime];
			}
		}
	}];
}

-(void)addFireworksEmitterAt:(SCNVector3)position withEmitterNode:(SCNNode*)emitterNode {
	[NezGCD dispatchBlock:^{
		NezNodeFireworksEmitter *particleEmitter = [self firstUnusedFireworksEmitter];
		if (!particleEmitter) {
			particleEmitter = [[NezNodeFireworksEmitter alloc] initWithMaxCount:250];
			[_emitterList addObject:particleEmitter];
		}
		[_scene.rootNode addChildNode:particleEmitter];
		particleEmitter.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_PARTICLES;
		particleEmitter.position = position;
		particleEmitter.emitter = emitterNode;
		
		GLuint texture = [NezAletterationGraphics particleTextureForName:@"star"];
		GLuint colorRamp = [NezAletterationGraphics particleTextureForName:[NSString stringWithFormat:@"ramp_%d", randomIntInRange(0, 5)]];
		
		[particleEmitter setupFireworksWithTexture:texture ColorRamp:colorRamp andCompletionHandler:^{
			[particleEmitter stopEmitting];
			[particleEmitter removeFromParentNode];
		}];
		[particleEmitter startEmitting];
	}];
}

-(NezNodeStarStreamerEmitter*)addStarStreamEmitterAt:(SCNVector3)position withEmitterNode:(SCNNode*)emitterNode {
	NezNodeStarStreamerEmitter *particleEmitter = [self firstUnusedStarStreamEmitter];
	if (!particleEmitter) {
		particleEmitter = [[NezNodeStarStreamerEmitter alloc] initWithMaxCount:50];
		[_emitterList addObject:particleEmitter];
	}
	[_scene.rootNode addChildNode:particleEmitter];
	particleEmitter.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_PARTICLES;
	particleEmitter.position = position;
	particleEmitter.emitter = emitterNode;
	
	GLuint texture = [NezAletterationGraphics particleTextureForName:@"radial"];
	GLuint colorRamp = [NezAletterationGraphics particleTextureForName:[NSString stringWithFormat:@"ramp_%d", randomIntInRange(0, 5)]];
	
	[particleEmitter setupStreamerWithTexture:texture ColorRamp:colorRamp andCompletionHandler:^{
		[particleEmitter stopEmitting];
		[particleEmitter removeFromParentNode];
	}];
	[particleEmitter startEmitting];
	return particleEmitter;
}

+(NezAletterationBigBox*)newBigBox {
	NezAletterationBigBox *box = [NezAletterationBigBox box];
	box.geometry = [gBigBoxGeometry copy];
	box.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_BIG_BOX;
	box.bodyMass = NEZ_ALETTERATION_GRAPHICS_BODY_MASS_BIG_BOX;
	box.restitution = NEZ_ALETTERATION_GRAPHICS_RESTITUTION_BIG_BOX;
	box.friction = NEZ_ALETTERATION_GRAPHICS_FRICTION_BIG_BOX;
	box.angularDamping = NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_BIG_BOX;
	box.sideThickness = gBigBoxSize.boxSideThickness;
	box.insideThickness = gBigBoxSize.boxBottomThickness;
	box.geometry.firstMaterial = [NezAletterationGraphics colorMaterial:[NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	
	return box;
}

+(NezAletterationBox*)newBigLid {
	NezAletterationBox *lid = [NezAletterationBox lid];
	lid.geometry = [gBigBoxLidGeometry copy];

	lid.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_BIG_LID;
	lid.bodyMass = NEZ_ALETTERATION_GRAPHICS_BODY_MASS_BIG_LID;
	lid.restitution = NEZ_ALETTERATION_GRAPHICS_RESTITUTION_BIG_LID;
	lid.friction = NEZ_ALETTERATION_GRAPHICS_FRICTION_BIG_LID;
	lid.angularDamping = NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_BIG_LID;
	lid.sideThickness = gBigBoxSize.lidSideThickness;
	lid.insideThickness = gBigBoxSize.lidTopThickness;
	lid.maximumLinearVelocity = GLKVector3Make(50.0, 50.0, 50.0);
	
	NezSurfaceColorMaterial *lidMaterial = [NezSurfaceColorMaterial materialWithShaderPath:[NezAletterationGraphics resourceShaderModiferPathWithFilename:@"AddSurfaceColorOneMinusAlpha"]];
	[NezAletterationGraphics setupMaterial:lidMaterial withTexturePath:[NezAletterationGraphics resourceTexturePathWithFilename:@"lid" Type:@"png" Dir:@"BigBox"]];
	lidMaterial.mu_SurfaceColor = SCNVector3Make(1.0, 1.0, 1.0);
	lidMaterial.mu_DiffuseTintColor = SCNVector3Make(1.0, 1.0, 1.0);
	lid.geometry.firstMaterial = lidMaterial;
	
	return lid;
}

+(NezAletterationGameBoard*)newGameBoard {
	NezAletterationGameBoard *gameBoard = [NezAletterationGameBoard board];
	gameBoard.color = SCNVector3Make(1.0, 1.0, 1.0);
	return gameBoard;
}

+(NezAletterationBox*)newSmallBox {
	NezAletterationBox *box = [NezAletterationBox box];
	box.geometry = [gLetterBoxGeometry copy];

	box.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_SMALL_BOX;
	box.bodyMass = NEZ_ALETTERATION_GRAPHICS_BODY_MASS_SMALL_BOX;
	box.restitution = NEZ_ALETTERATION_GRAPHICS_RESTITUTION_SMALL_BOX;
	box.friction = NEZ_ALETTERATION_GRAPHICS_FRICTION_SMALL_BOX;
	box.angularDamping = NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_SMALL_BOX;
	box.sideThickness = gSmallBoxSize.boxSideThickness;
	box.insideThickness = gSmallBoxSize.boxBottomThickness;
	box.geometry.firstMaterial = [NezAletterationGraphics colorMaterial:[NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	
	return box;
}

+(NezAletterationBox*)newSmallLid {
	NezAletterationBox *lid = [NezAletterationBox lid];
	lid.geometry = [gLetterBoxLidGeometry copy];

	lid.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_SMALL_LID;
	lid.bodyMass = NEZ_ALETTERATION_GRAPHICS_BODY_MASS_SMALL_LID;
	lid.restitution = NEZ_ALETTERATION_GRAPHICS_RESTITUTION_SMALL_LID;
	lid.friction = NEZ_ALETTERATION_GRAPHICS_FRICTION_SMALL_LID;
	lid.angularDamping = NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_SMALL_LID;
	lid.sideThickness = gSmallBoxSize.lidSideThickness;
	lid.insideThickness = gSmallBoxSize.lidTopThickness;
	lid.collisionMinBounce = GLKVector3Make(-10.0, -10.0, -10.0);
	lid.collisionMaxBounce = GLKVector3Make(10.0, 10.0, 10.0);
	lid.maximumLinearVelocity = GLKVector3Make(50.0, 50.0, 50.0);
	
	NezSurfaceColorMaterial *lidMaterial = [NezSurfaceColorMaterial materialWithShaderPath:[NezAletterationGraphics resourceShaderModiferPathWithFilename:@"AddSurfaceColorOneMinusAlpha"]];
	[NezAletterationGraphics setupMaterial:lidMaterial withTexturePath:[NezAletterationGraphics resourceTexturePathWithFilename:@"lid" Type:@"png" Dir:@"Box"]];
	lidMaterial.mu_SurfaceColor = SCNVector3Make(1.0, 1.0, 1.0);
	lidMaterial.mu_DiffuseTintColor = SCNVector3Make(1.0, 1.0, 1.0);
	lid.geometry.firstMaterial = lidMaterial;
	
	return lid;
}

+(NezAletterationWordLine*)newWordLine {
	NezAletterationWordLine *wordLine = [NezAletterationWordLine wordLine];
	wordLine.geometry = [gWordLineGeometry copy];
	wordLine.geometry.firstMaterial = [NezAletterationGraphics colorMaterial:[NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	wordLine.geometry.firstMaterial.writesToDepthBuffer = NO;
	wordLine.geometry.firstMaterial.readsFromDepthBuffer = NO;
	wordLine.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_WORD_LINE;
	return wordLine;
}

+(NSArray*)newLetterBlockList {
	NSMutableArray *letterBlockList = [NSMutableArray array];
	
	SCNVector3 color = SCNVector3Make(1.0, 1.0, 1.0);
	
	NezSurfaceColorMaterial *frontMaterial = [NezSurfaceColorMaterial materialWithShaderPath:[NezAletterationGraphics resourceShaderModiferPathWithFilename:@"AddSurfaceColorOneMinusAlpha"]];
	[NezAletterationGraphics setupMaterial:frontMaterial withTexturePath:[NezAletterationGraphics resourceTexturePathWithFilename:@"00" Type:@"png" Dir:@"Letters"]];
	frontMaterial.mu_SurfaceColor = color;

//	SCNMaterial *frontMaterial = [NezAletterationGraphics colorMaterial:[NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	
//	frontMaterial.normal.contents = [NezAletterationGraphics resourceTexturePathWithFilename:@"nm3" Type:@"png" Dir:@"Letters"];
//	frontMaterial.normal.mipFilter = SCNLinearFiltering; //we also want to preload mipmaps
//	frontMaterial.normal.intensity = 1.3;
	
	NSInteger boxColumnIndex = 1;
	
	NezAletterationLetterBag letterBag = [NezAletterationGameState fullLetterBag];
	int letterCount = 0;
	for (int letterIndex=0;letterIndex<NEZ_ALETTERATION_ALPHABET_COUNT;letterIndex++) {
		if (letterIndex == 7 || letterIndex == 15) {
			letterCount = 0;
			boxColumnIndex--;
		}
		if (letterIndex == NEZ_ALETTERATION_ALPHABET_COUNT-1) {
			boxColumnIndex = 0;
			letterCount--;
		}
		int count=letterBag.count[letterIndex];
		for (int j=0; j<count; j++) {
//			NezAletterationLetterBlock *letterBlock = [self newLetterBlockWithLetter:'a'+letterIndex FrontMaterial:nil];
//			letterBlock.geometry.firstMaterial = [frontMaterial copy];
//			letterBlock.letter = letterBlock.letter;
			NezAletterationLetterBlock *letterBlock = [self newLetterBlockWithLetter:'a'+letterIndex FrontMaterial:frontMaterial];
			letterBlock.color = color;
			letterBlock.stackIndex = j;
			letterBlock.boxRowIndex = letterCount+(count-j-1);
			letterBlock.boxColumnIndex = boxColumnIndex;
			[letterBlockList addObject:letterBlock];
		}
		letterCount += count;
	}
	return [NSArray arrayWithArray:letterBlockList];
}

+(NezAletterationLetterBlock*)newLetterBlockWithLetter:(char)letter FrontMaterial:(NezSurfaceColorMaterial*)frontMaterial {
	NezAletterationLetterBlock *letterBlock = [NezAletterationLetterBlock blockWithLetter:letter andFrontMaterial:[frontMaterial copy]];
	letterBlock.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_LETTER_BLOCK;
	
	letterBlock.bodyMass = NEZ_ALETTERATION_GRAPHICS_BODY_MASS_LETTER_BLOCK;
	letterBlock.restitution = NEZ_ALETTERATION_GRAPHICS_RESTITUTION_LETTER_BLOCK;
	letterBlock.friction = NEZ_ALETTERATION_GRAPHICS_FRICTION_LETTER_BLOCK;
	letterBlock.angularDamping = NEZ_ALETTERATION_GRAPHICS_ANGULAR_DAMPING_LETTER_BLOCK;

	letterBlock.geometry = [gLetterBlockGeometry copy];
	if (letterBlock.frontMaterial) {
		letterBlock.geometry.firstMaterial = letterBlock.frontMaterial;
	}

	return letterBlock;
}

+(void)setupMaterial:(SCNMaterial*)material withTexturePath:(NSString*)texturePath {
	material.diffuse.contents  = texturePath;
	material.diffuse.mipFilter = SCNLinearFiltering; //we also wan't to preload mipmaps
	material.ambient.contents = texturePath;
	material.ambient.mipFilter = SCNLinearFiltering; //we also wan't to preload mipmaps
	material.ambient.intensity = 0.75;
	
	material.specular.contents = [NSColor whiteColor];
	material.specular.intensity = 0.5;
	material.shininess = 0.5;
}

+(SCNMaterial*)textureMaterial:(NSString*)texturePath {
	SCNMaterial *material = [SCNMaterial material];
	[NezAletterationGraphics setupMaterial:material withTexturePath:texturePath];
	return material;
}

+(SCNMaterial*)colorMaterial:(NSColor*)color {
	SCNMaterial *material = [SCNMaterial material];
	[self setupMaterial:material withColor:color];
	return material;
}

+(void)setupMaterial:(SCNMaterial*)material withColor:(NSColor*)color {
	material.diffuse.contents  = color;
	material.ambient.contents = color;
	material.ambient.intensity = 0.75;
	
	material.specular.contents = [NSColor whiteColor];
	material.specular.intensity = 0.5;
	material.shininess = 0.5;
}

-(NSArray*)dynamicNodeList {
	return _dynamicNodeList;
}

-(SCNNode*)spotLightNode {
	return _spotLightNode;
}

-(SCNScene*)scene {
	return _scene;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GLKVector3 getTriangleNormal(GLKVector3 v0, GLKVector3 v1, GLKVector3 v2) {
	return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(v1, v0), GLKVector3Subtract(v2, v0)));
}

BoxSize writeBox(NSString *name, TriangleIndex *t, float innerHeight, float lidRatio, float lidDepthRatio, float boxDepth, float sideThicknessRatio, float bottomThicknessRatio) {
	GLKVector3 v[17];
	
	float sideThickness = innerHeight*sideThicknessRatio;
	
	float boxHeight = innerHeight+sideThickness*2.0;
	
	float space = 0.015625*boxHeight;
	float lidHeight = boxHeight+space+sideThickness*2.0;
	float lidWidth = lidHeight*lidRatio;
	float lidDepth = lidWidth*lidDepthRatio;
	
	float boxWidth = lidWidth-sideThickness*2.0-space;
	
	float boxBottomThickness = boxDepth*bottomThicknessRatio;
	boxDepth += boxBottomThickness;
	
	makeBoxTriangleVertexList(v, lidWidth, lidHeight, lidDepth, sideThickness, lidDepth*bottomThicknessRatio, YES);
	writeObj([NSString stringWithFormat:@"%@Lid", name], v, t, 16, 28);
	makeBoxTriangleVertexList(v, boxWidth, boxHeight, boxDepth, sideThickness, boxBottomThickness, NO);
	writeObj(name, v, t, 16, 28);
	
	BoxSize size;
	
	size.lidW = lidWidth;
	size.lidH = lidHeight;
	size.lidD = lidDepth;
	size.lidTopThickness = lidDepth*bottomThicknessRatio;
	size.lidSideThickness = sideThickness;
	
	size.boxW = boxWidth;
	size.boxH = boxHeight;
	size.boxD = boxDepth;
	size.boxBottomThickness = boxBottomThickness;
	size.boxSideThickness = sideThickness;
	
	return size;
}

void writeObj(NSString *name, GLKVector3 *v, TriangleIndex *t, int vertexCount, int triangleCount) {
	NSMutableArray *normalList = [NSMutableArray array];
	for (int i=0; i<triangleCount; i++) {
		GLKVector3 n = getTriangleNormal(v[t[i].v0.v], v[t[i].v1.v], v[t[i].v2.v]);
		Vector3Object *vObject = [[Vector3Object alloc] init];
		vObject.vec3 = n;
		
		if (![normalList containsObject:vObject]) {
			[normalList addObject:vObject];
		}
		unsigned long index = [normalList indexOfObject:vObject]+1;
		t[i].v0.n = index;
		t[i].v1.n = index;
		t[i].v2.n = index;
		
		t[i].v0.t = 1;
		t[i].v1.t = 1;
		t[i].v2.t = 1;
	}
	NSString *path = [NSString stringWithFormat:@"/Users/david/Desktop/Models/%@/%@.obj", name, name];
	FILE *objFile = fopen([path UTF8String], "w");
	for (int i=1; i<=vertexCount; i++) {
		fprintf(objFile, "v % f % f % f \n", v[i].x, v[i].y, v[i].z);
	}
	for (Vector3Object *normal in normalList) {
		fprintf(objFile, "vn % f % f % f \n", normal.vec3.x, normal.vec3.y, normal.vec3.z);
	}
	
	fprintf(objFile, "vt 0.0000 0.0000 0.0000\n");
	
	fprintf(objFile, "g %s\n", [name UTF8String]);
	for (int i=0; i<triangleCount; i++) {
		fprintf(objFile, "f %lu/%lu/%lu %lu/%lu/%lu %lu/%lu/%lu \n", t[i].v0.v, t[i].v0.t, t[i].v0.n, t[i].v1.v, t[i].v1.t, t[i].v1.n, t[i].v2.v, t[i].v2.t, t[i].v2.n);
	}
	fclose(objFile);
}

void writeLetterBlock(float width, float depth) {
	GLKVector3 v[9];
	float x = width/2.0, y = width/2.0, z = depth/2.0;
	
	int i=0;
	v[i++] = GLKVector3Make(0,  0, 0);
	v[i++] = GLKVector3Make(-x, -y,  z);//1
	v[i++] = GLKVector3Make(-x,  y,  z);//2
	v[i++] = GLKVector3Make( x, -y,  z);//3
	v[i++] = GLKVector3Make( x,  y,  z);//4
	v[i++] = GLKVector3Make( x, -y, -z);//5
	v[i++] = GLKVector3Make( x,  y, -z);//6
	v[i++] = GLKVector3Make(-x, -y, -z);//7
	v[i++] = GLKVector3Make(-x,  y, -z);//8
	
	TriangleIndex t[12] = {
		{{4},{2},{1}},
		{{6},{4},{3}},
		{{8},{6},{5}},
		{{2},{8},{7}},
		{{6},{8},{2}},
		{{3},{1},{7}},
		{{3},{4},{1}},
		{{5},{6},{3}},
		{{7},{8},{5}},
		{{1},{2},{7}},
		{{4},{6},{2}},
		{{5},{3},{7}},
	};
	
	writeObj(@"LetterBlock", v, t, 8, 12);
}

void makeBoxTriangleVertexList(GLKVector3 v[17], float w, float h, float d, float st, float bt, BOOL isLid) {
	float ox = w/2.0, oy = h/2.0, oz = d/2.0;
	float ix = ox-st, iy = oy-st, iz = oz-bt;
	
	int i=0;
	v[i++] = GLKVector3Make(0,  0, 0);
	v[i++] = GLKVector3Make( ox*(isLid?-1.0:1.0),  oy,  -oz*(isLid?-1.0:1.0));//1
	v[i++] = GLKVector3Make(-ox*(isLid?-1.0:1.0),  oy,  -oz*(isLid?-1.0:1.0));//2
	v[i++] = GLKVector3Make(-ox*(isLid?-1.0:1.0),  oy,   oz*(isLid?-1.0:1.0));//3
	v[i++] = GLKVector3Make( ox*(isLid?-1.0:1.0), -oy,  -oz*(isLid?-1.0:1.0));//4
	v[i++] = GLKVector3Make( ox*(isLid?-1.0:1.0),  oy,   oz*(isLid?-1.0:1.0));//5
	v[i++] = GLKVector3Make(-ox*(isLid?-1.0:1.0), -oy,  -oz*(isLid?-1.0:1.0));//6
	v[i++] = GLKVector3Make( ox*(isLid?-1.0:1.0), -oy,   oz*(isLid?-1.0:1.0));//7
	v[i++] = GLKVector3Make(-ox*(isLid?-1.0:1.0), -oy,   oz*(isLid?-1.0:1.0));//8
	v[i++] = GLKVector3Make(-ix*(isLid?-1.0:1.0), -iy,  -iz*(isLid?-1.0:1.0));//9
	v[i++] = GLKVector3Make( ix*(isLid?-1.0:1.0), -iy,  -iz*(isLid?-1.0:1.0));//10
	v[i++] = GLKVector3Make( ix*(isLid?-1.0:1.0),  iy,  -iz*(isLid?-1.0:1.0));//11
	v[i++] = GLKVector3Make(-ix*(isLid?-1.0:1.0),  iy,   oz*(isLid?-1.0:1.0));//12
	v[i++] = GLKVector3Make( ix*(isLid?-1.0:1.0),  iy,   oz*(isLid?-1.0:1.0));//13
	v[i++] = GLKVector3Make(-ix*(isLid?-1.0:1.0), -iy,   oz*(isLid?-1.0:1.0));//14
	v[i++] = GLKVector3Make( ix*(isLid?-1.0:1.0), -iy,   oz*(isLid?-1.0:1.0));//15
	v[i++] = GLKVector3Make(-ix*(isLid?-1.0:1.0),  iy,  -iz*(isLid?-1.0:1.0));//16
}

@end
