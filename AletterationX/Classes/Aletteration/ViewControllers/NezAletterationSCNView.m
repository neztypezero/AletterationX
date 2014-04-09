//
//  NezSCNViewController.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/10.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationSCNView.h"
#import "NezAletterationGeometry.h"
#import "NezSimpleObjLoader.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationBulletPhysics.h"
#import "NezAletterationSCNView.h"
#import "NezGCD.h"
#import "NezRandom.h"
#import "NezGLKUtil.h"
#import "NezFogVAO.h"
#import "NezGLSLProgram.h"
#import "NezGLSLProgramFog.h"
#import "NezFXAAVAO.h"
#import "NezGLSLProgramFXAA.h"
#import "NezVertex2VBO.h"
#import "NezVboVertexP4T2.h"
#import "NezGBuffer.h"

static CVReturn nezSCNViewCVDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                                const CVTimeStamp *inNow,
                                                const CVTimeStamp *inOutputTime,
                                                CVOptionFlags flagsIn,
                                                CVOptionFlags *flagsOut,
                                                void *displayLinkContext)
{
	return [(__bridge NezAletterationSCNView*)displayLinkContext stepFrameForTime:inOutputTime];
}

@interface NezSceneLoader : NSObject<SCNSceneRendererDelegate>

+(instancetype)loaderWithView:(NezAletterationSCNView*)view;
-(instancetype)initWithView:(NezAletterationSCNView*)view;

@end

@interface NezAletterationSCNView(Loading)

@property (retain, getter = loader, setter = setLoader:) NezSceneLoader *loader;

-(void)initScene;

@end

@implementation NezSceneLoader {
	NezAletterationSCNView *_view;
}

+(instancetype)loaderWithView:(NezAletterationSCNView*)view {
	return [[NezSceneLoader alloc] initWithView:view];
}

-(instancetype)initWithView:(NezAletterationSCNView*)view {
	if ((self = [super init])) {
		_view = view;
	}
	return self;
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		_view.loader = nil;
		_view.delegate = nil;
		[_view initScene];
		_view.delegate = _view;
		_view = nil;
	});
}
@end

@implementation NezAletterationSCNView {
	NSNotificationCenter *_notificationCenter;
	NezAletterationGraphics *_graphics;
	NezAletterationBulletPhysics *_physics;
	NezAletterationGameTable *_gameTable;
	NezAnimator *_kinematicsAnimator;
	
	NSDictionary *_cameraDictionary;

	CVDisplayLinkRef _displayLink;
	
	NezAletterationInputController *_currentInputController;
	NSMutableDictionary *_inputControllerDictionary;

	// Fog Variables
	GLuint _colorTexture, _depthTexture;
	GLuint _fbo; //offscreen framebuffer
	GLuint _screenKitFBO; //ScreenKit framebuffer
	NezFogVAO *_fogVAO;
	NezFXAAVAO *_fxaaVAO;
	
	NezGBuffer *_gbuffer;

	NezSceneLoader *_loader;
	
	NSSize _bufferSize;
}

-(NezSceneLoader*)loader {
	return _loader;
}

-(void)setLoader:(NezSceneLoader*)loader {
	_loader = loader;
}

-(void)awakeFromNib {
	NSOpenGLPixelFormatAttribute attributes [] = {
		NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
		(NSOpenGLPixelFormatAttribute)0
	};
	self.pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];

	[self setWantsLayer:YES];
	self.loader = [NezSceneLoader loaderWithView:self];
	self.delegate = self.loader;
	self.scene = [SCNScene scene];
}

-(BOOL)acceptsFirstResponder {
	return YES;
}

//-(void)windowWillEnterFullScreen:(NSNotification *)notification {
//	[self stopCVDisplayLink];
//	[self pauseLayer:self.layer];
//}
//
//-(void)windowDidEnterFullScreen:(NSNotification *)notification {
//	[self startCVDisplayLink];
//	[self resumeLayer:self.layer];
//}
//
//-(void)windowWillExitFullScreen:(NSNotification *)notification {
//	[self stopCVDisplayLink];
//	[self pauseLayer:self.layer];
//}
//
//-(void)windowDidExitFullScreen:(NSNotification *)notification {
//	[self startCVDisplayLink];
//	[self resumeLayer:self.layer];
//}
//
//-(void)pauseLayer:(CALayer*)layer {
//	CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
//	layer.speed = 0.0;
//	layer.timeOffset = pausedTime;
//}
//
//-(void)resumeLayer:(CALayer*)layer {
//	CFTimeInterval pausedTime = [layer timeOffset];
//	layer.speed = 1.0;
//	layer.timeOffset = 0.0;
//	layer.beginTime = 0.0;
//	CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
//	layer.beginTime = timeSincePause;
//}

-(void)startCVDisplayLink {
	CVReturn error = kCVReturnSuccess;
	error = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	if (error) {
		NSLog(@"DisplayLink created with error:%d", error);
		_displayLink = NULL;
	}
	CVDisplayLinkSetOutputCallback(_displayLink, nezSCNViewCVDisplayLinkCallback, (__bridge void *)self);
	CVDisplayLinkStart(_displayLink);
}

-(void)stopCVDisplayLink {
	CVDisplayLinkStop(_displayLink);
	CVDisplayLinkRelease(_displayLink);
}

-(CVReturn)stepFrameForTime:(const CVTimeStamp *)outputTime {
	@autoreleasepool {
		CFTimeInterval elapsedTime = (1.0 / (outputTime->rateScalar * (double)outputTime->videoTimeScale / (double)outputTime->videoRefreshPeriod));
		
		[NezGCD runOnQueue:self.physics.dynamicsQueue WithWorkBlock:^{
			for (NezDynamicNode *dynamicNode in self.graphics.dynamicNodeList) {
				[dynamicNode stepSimulationWithElapsedTime:elapsedTime];
			}
			[self.kinematicsAnimator updateWithTimeSinceLastUpdate:elapsedTime];
			[self.physics stepSimulationWithElapsedTime:elapsedTime];
		} DoneBlock:^{
			for (NezDynamicNode *dynamicNode in self.graphics.dynamicNodeList) {
				[dynamicNode synchronizePosition];
			}
		}];
		[_graphics updateWithTimeSinceLastUpdate:elapsedTime];
	}
	return kCVReturnSuccess;
}

-(NezAletterationGraphics*)graphics {
	return _graphics;
}

-(NezAletterationBulletPhysics*)physics {
	return _physics;
}

-(NezAnimator*)kinematicsAnimator {
	return _kinematicsAnimator;
}

-(NSNotificationCenter*)notificationCenter {
	return _notificationCenter;
}

-(void)initScene {
	_notificationCenter = [[NSNotificationCenter alloc] init];
	
	[self setupOffscreenFramebuffer:NSMakeSize(2560, 1440)];
	
	self.allowsCameraControl = YES;
	self.jitteringEnabled = NO;
	self.showsStatistics = YES;
	
	SCNVector3 zero = SCNVector3Make(0.0, 0.0, 0.0);
	SCNVector3 zUp = SCNVector3Make(0.0, 0.0, 1.0);
	
	_graphics = [NezAletterationGraphics graphicsWithContext:[self openGLContext]];
	_physics = [NezAletterationBulletPhysics physicsWithDynamicNodeList:_graphics.dynamicNodeList];
	_gameTable = _graphics.gameTable;
	_kinematicsAnimator = [NezAnimator animator];
	
	SCNScene *scene = _graphics.scene;
	
	_cameraDictionary = @{
		NEZ_ALETTERATION_CAMERA_BIG_BOX:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_BIG_BOX LookAtNode:_graphics.gameTable.lid Z:75 toScene:_graphics.scene],
		
		NEZ_ALETTERATION_CAMERA_PLAYER0_GAMEBOARD:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER0_GAMEBOARD LookAtNode:[_gameTable playerForIndex:0].gameBoard Z:60 toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER1_GAMEBOARD:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER1_GAMEBOARD LookAtNode:[_gameTable playerForIndex:1].gameBoard Z:60 toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER2_GAMEBOARD:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER2_GAMEBOARD LookAtNode:[_gameTable playerForIndex:2].gameBoard Z:60 toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER3_GAMEBOARD:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER3_GAMEBOARD LookAtNode:[_gameTable playerForIndex:3].gameBoard Z:60 toScene:scene],
		
		NEZ_ALETTERATION_CAMERA_PLAYER0_STARTING:[self addCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER0_STARTING Eye:[self eyePositionForGameBoard:[_gameTable playerForIndex:0].gameBoard] Center:zero Up:zUp toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER1_STARTING:[self addCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER1_STARTING Eye:[self eyePositionForGameBoard:[_gameTable playerForIndex:1].gameBoard] Center:zero Up:zUp toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER2_STARTING:[self addCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER2_STARTING Eye:[self eyePositionForGameBoard:[_gameTable playerForIndex:2].gameBoard] Center:zero Up:zUp toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER3_STARTING:[self addCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER3_STARTING Eye:[self eyePositionForGameBoard:[_gameTable playerForIndex:3].gameBoard] Center:zero Up:zUp toScene:scene],

		NEZ_ALETTERATION_CAMERA_PLAYER0_RETIRED_WORDS:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER0_RETIRED_WORDS LookAtNode:[_gameTable playerForIndex:0].gameBoard.retiredWordBoard Z:60 toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER1_RETIRED_WORDS:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER1_RETIRED_WORDS LookAtNode:[_gameTable playerForIndex:1].gameBoard.retiredWordBoard Z:60 toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER2_RETIRED_WORDS:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER2_RETIRED_WORDS LookAtNode:[_gameTable playerForIndex:2].gameBoard.retiredWordBoard Z:60 toScene:scene],
		NEZ_ALETTERATION_CAMERA_PLAYER3_RETIRED_WORDS:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_PLAYER3_RETIRED_WORDS LookAtNode:[_gameTable playerForIndex:3].gameBoard.retiredWordBoard Z:60 toScene:scene],

		NEZ_ALETTERATION_CAMERA_FULL_OVERVIEW:[self addLookDownCameraNodeWithName:NEZ_ALETTERATION_CAMERA_FULL_OVERVIEW LookAtNode:scene.rootNode Z:250 toScene:_graphics.scene],
	};

	self.scene = scene;
	
	self.pointOfView = _cameraDictionary[NEZ_ALETTERATION_CAMERA_BIG_BOX];
	
	self.backgroundColor = [NSColor colorWithRed:0.0980 green:0.098 blue:0.098 alpha:1.0];

	[self startCVDisplayLink];
	[self startUp];
}

-(SCNVector3)eyePositionForGameBoard:(NezAletterationGameBoard*)gameBoard {
	GLKTransform t = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(gameBoard.transform));
	
	GLKVector3 position = t.position;
	float distance = GLKVector3Distance(GLKVector3Make(0.0, 0.0, 0.0), position);
	GLKVector3 eyePosition = GLKQuaternionRotateVector3(t.orientation, GLKVector3Make(distance*0.5, -distance*2.0, distance*0.65));
	
	return SCNVector3FromGLKVector3(eyePosition);
}

-(void)animateToRandomCameraWithCompletionHandler:(NezVoidBlock)completionHandler {
	NSInteger count = _cameraDictionary.count;
	if (count > 0) {
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:6.0];
		[SCNTransaction setCompletionBlock:completionHandler];
		NSInteger index = (NSInteger)(randomFloat()*count);
		self.pointOfView = _cameraDictionary.allValues[index];
		[SCNTransaction commit];
	}
}

-(SCNNode*)addCameraNodeWithName:(NSString*)name Eye:(SCNVector3)eye Center:(SCNVector3)center Up:(SCNVector3)up toScene:(SCNScene*)scene {
	bool isInv;
	SCNNode *cameraNode = [self makeCameraNodeWithName:name];
	cameraNode.transform = GLKMatrix4ToCATransform3D(GLKMatrix4Invert(GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z), &isInv));
	[scene.rootNode addChildNode:cameraNode];
	return cameraNode;
}

-(SCNNode*)addLookDownCameraNodeWithName:(NSString*)name LookAtNode:(SCNNode*)lookAtNode Z:(float)z toScene:(SCNScene*)scene {
	CATransform3D transform = CATransform3DTranslate([lookAtNode convertTransform:CATransform3DIdentity toNode:nil], 0.0, 0.0, z);
	GLKTransform t = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(transform));
	SCNVector3 up = SCNVector3FromGLKVector3(GLKQuaternionRotateVector3(t.orientation, GLKVector3Make(0.0, 1.0, 0.0)));
	return [self addCameraNodeWithName:name Eye:SCNVector3FromGLKVector3(t.position) Center:[lookAtNode convertPosition:SCNVector3Make(0.0, 0.0, 0.0) toNode:nil] Up:up toScene:scene];
}

-(SCNNode*)makeCameraNodeWithName:(NSString*)name {
	SCNCamera *camera = [SCNCamera camera];
	camera.xFov = 45;   // Degrees, not radians
	camera.yFov = 45;
	camera.zNear = 1.0f;
	camera.zFar = 1500.0f;
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = camera;
	camera.name = name;
	cameraNode.name = name;

	return cameraNode;
}

-(BOOL)setCameraForName:(NSString*)cameraName {
	if (cameraName && _cameraDictionary[cameraName]) {
		SCNNode *cameraNode = _cameraDictionary[cameraName];
		self.pointOfView = cameraNode;
		return YES;
	}
	return NO;
}

-(void)animateToCameraForName:(NSString*)cameraName withDuration:(CFTimeInterval)duration andCompletionBlock:(NezVoidBlock)completionHandler {
	if (_cameraDictionary[cameraName]) {
		[NezGCD dispatchBlock:^{
			[SCNTransaction begin];
			[SCNTransaction setAnimationDuration:duration];
			if (completionHandler) {
				[SCNTransaction setCompletionBlock:completionHandler];
			}
			self.pointOfView = _cameraDictionary[cameraName];
			[SCNTransaction commit];
		}];
	}
}


-(void)startUp {
	[self initInputControllers];
}

-(void)initInputControllers {
	_inputControllerDictionary = [NSMutableDictionary dictionary];
	
	int opts = (NSTrackingActiveInKeyWindow | NSTrackingMouseMoved);
	[self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil]];
	
	NezAletterationGameController *mainInputController = [[NezAletterationGameController alloc] initWithNezAletterationSCNView:self];
	_inputControllerDictionary[@"mainInputController"] = mainInputController;
	
	self.inputController = mainInputController;
}

-(NezAletterationInputController*)inputController {
	return _currentInputController;
}

-(void)setInputController:(NezAletterationInputController*)inputController {
	if (_currentInputController) {
		[_currentInputController controllerRemoved];
	}
	_currentInputController = inputController;
	[_currentInputController controllerAdded];
}

-(void)mouseDown:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController mouseDown:theEvent];
	}
	[super mouseDown:theEvent];
}

-(void)mouseMoved:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController mouseMoved:theEvent];
	}
	[super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController mouseDragged:theEvent];
	}
	[super mouseDown:theEvent];
}

-(void)mouseUp:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController mouseUp:theEvent];
	}
	[super mouseUp:theEvent];
}

-(void)rightMouseDown:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController rightMouseDown:theEvent];
	}
	[super rightMouseDown:theEvent];
}

-(void)rightMouseDragged:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController rightMouseDragged:theEvent];
	}
	[super rightMouseDragged:theEvent];
}

-(void)rightMouseUp:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController rightMouseUp:theEvent];
	}
	[super rightMouseUp:theEvent];
}

-(void)otherMouseDown:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController otherMouseDown:theEvent];
	}
	[super otherMouseDown:theEvent];
}

-(void)otherMouseDragged:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController otherMouseDragged:theEvent];
	}
	[super otherMouseDragged:theEvent];
}

-(void)otherMouseUp:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController otherMouseUp:theEvent];
	}
	[super otherMouseUp:theEvent];
}

-(void)mouseEntered:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController mouseEntered:theEvent];
	}
	[super mouseEntered:theEvent];
}

-(void)mouseExited:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController mouseExited:theEvent];
	}
	[super mouseExited:theEvent];
}

-(void)keyDown:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController keyDown:theEvent];
	}
}

-(void)keyUp:(NSEvent *)theEvent {
	if (_currentInputController) {
		[_currentInputController keyUp:theEvent];
	}
}

-(void)setupOffscreenFramebuffer:(NSSize)size {
	_bufferSize = size;
	
	//release previous renderer if any
	if(_fbo) {
		glDeleteTextures(1, &_colorTexture);
		glDeleteTextures(1, &_depthTexture);
		glDeleteFramebuffers(1, &_fbo);
	}
	glGenTextures(1, &_colorTexture);
	glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, _colorTexture);
	glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, 4, GL_RGBA8, _bufferSize.width, _bufferSize.height, GL_FALSE);
	
	glGenTextures(1, &_depthTexture);
	glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, _depthTexture);
	glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, 4, GL_DEPTH_COMPONENT32, _bufferSize.width, _bufferSize.height, GL_FALSE);
	
	glGenFramebuffers(1, &_fbo);
	glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
	glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _colorTexture, 0);
	glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, _depthTexture, 0);

	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (status != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"failed to create the FBO : %x", status);
	}
	//unbind for now
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
//
//	const NezVertexP4T2 vertices[] = {
//		{{-1,-1, 0, 1}, { 0, 0}},
//		{{ 1,-1, 0, 1}, { 1, 0}},
//		{{ 1, 1, 0, 1}, { 1, 1}},
//		{{-1, 1, 0, 1}, { 0, 1}},
//	};
//	NSData *vertexData = [NSData dataWithBytes:vertices length:sizeof(vertices)];
//	const GLushort indices[] = {0,1,2,0,2,3};
//	NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];

//	_fogVAO = [[NezFogVAO alloc] initWithVertexBufferObject:[[NezVertex2VBO alloc] initWithVertexData:[NSData dataWithBytes:vertices length:sizeof(vertices)] andIndexData:[NSData dataWithBytes:indices length:sizeof(indices)]]];
//	_fogVAO.program = [NezGLSLProgramFog program];
//	_fogVAO.colorTexture = _colorTexture;
//	_fogVAO.depthTexture = _depthTexture;
	
//	_fxaaVAO = [[NezFXAAVAO alloc] initWithVertexBufferObject:[[NezVboVertexP4T2 alloc] initWithVertexData:vertexData andIndexData:indexData]];
//	_fxaaVAO.program = [NezGLSLProgramFXAA program];
//	_fxaaVAO.texture0 = _colorTexture;
//	
//	_gbuffer = [NezGBuffer gbufferWithWidth:size.width andHeight:size.height];
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
	GLint fbo;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fbo);
	if (fbo && _fbo) {
		_screenKitFBO = fbo;
		
		//bind our fbo so that scenekit renders into it
		glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
		//clear
		glClearColor(0.0980, 0.098, 0.098, 1.0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		glEnable(GL_MULTISAMPLE);
	}
}

-(void)renderer:(id<SCNSceneRenderer>)aRenderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
	if (_screenKitFBO && _fbo) {
		glDisable(GL_MULTISAMPLE);
		
		glBindFramebuffer(GL_READ_FRAMEBUFFER, _fbo);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _screenKitFBO);
		
		glBlitFramebuffer(0, 0, _bufferSize.width, _bufferSize.height, 0, 0, _bufferSize.width, _bufferSize.height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
	}
}

@end
