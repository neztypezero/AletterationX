//
//  NezAletterationMainViewController.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/09.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "NezAletterationSCNView.h"
#import "NezAletterationGameController.h"
#import "NezAletterationGeometry.h"
#import "NezAletterationGameState.h"
#import "NezRandom.h"
#import "NezAnimator.h"
#import "NezAnimationEasingFunction.h"
#import "NezPaths.h"
#import "NezGLKUtil.h"
#import "NezAletterationPlayerNotifications.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationDefinition.h"
#import "NezNodeFireworksEmitter.h"
#import "NezNodeStarStreamerEmitter.h"
#import "NezAletterationDefinitionBubble.h"
#import "NezClickableNode.h"
#import "NezXML.h"

typedef void (^ NezURLResponseHandler)(NSURLResponse *response, NSData *data, NSError *connectionError);

#define NEZ_ALETTERATION_RIGID_BODY_CONSTRAINT_BIG_BOX_NO_MOVE @"constraint_bigBox_no_move"

@interface NezAletterationNodeAnimationContainer : NSObject

@property NezDynamicNode *node;
@property GLKTransform startTransform;
@property GLKTransform endTransform;

@end

@implementation NezAletterationNodeAnimationContainer

+(instancetype)containerWithNode:(NezDynamicNode*)node Start:(GLKTransform)startTransform End:(GLKTransform)endTransform {
	return [[self alloc] initWithNode:node Start:startTransform End:endTransform];
}

-(instancetype)initWithNode:(NezDynamicNode*)node Start:(GLKTransform)startTransform End:(GLKTransform)endTransform {
	if ((self = [super init])) {
		self.node = node;
		self.startTransform = startTransform;
		self.endTransform = endTransform;
	}
	return self;
}

@end

@implementation NezAletterationGameController {
	NezAnimator *_kinematicsAnimator;

	NezAletterationGraphics *_graphics;
	NezAletterationGameTable *_gameTable;
	NezAletterationBulletPhysics *_physics;
	dispatch_queue_t _dynamicsQueue;
	
	NSNotificationCenter *_notificationCenter;
	
	BOOL _animationRandomCamera;
}

-(instancetype)initWithNezAletterationSCNView:(NezAletterationSCNView*)nezSCNAletterationView {
	if ((self = [super initWithNezAletterationSCNView:nezSCNAletterationView])) {
		_kinematicsAnimator = self.nezSCNAletterationView.kinematicsAnimator;
		_graphics = self.nezSCNAletterationView.graphics;
		_gameTable = _graphics.gameTable;
		_physics = self.nezSCNAletterationView.physics;
		_dynamicsQueue = _physics.dynamicsQueue;
		_notificationCenter = self.nezSCNAletterationView.notificationCenter;
	}
	return self;
}

-(dispatch_queue_t)dynamicsQueue {
	return _dynamicsQueue;
}

-(NezAnimator*)kinematicsAnimator {
	return _kinematicsAnimator;
}

-(NSNotificationCenter*)notificationCenter {
	return _notificationCenter;
}

-(void)runBlock:(NezVoidBlock)block whenNodeIsNotActive:(NezDynamicNode*)node {
	if (block) {
		if (node.rigidBodyIsActive) {
			[NezGCD dispatchBlock:^{
				[self runBlock:[block copy] whenNodeIsNotActive:node];
			} afterMilliseconds:50.0];
		} else {
			block();
		}
	}
}

-(void)htmlElements:(NSArray*)elementList toAttributedStrings:(NSMutableArray*)stringList {
	for (NezXMLElement *element in elementList) {
		NSString *raw = element.raw;
		if (raw && raw.length > 0) {
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:[raw dataUsingEncoding:NSUnicodeStringEncoding] options:nil documentAttributes:nil];
			if (attributedString.length > 10) {
				[stringList addObject:attributedString];
			}
		}
	}
}

-(void)controllerAdded {
	[_notificationCenter addObserver:self selector:@selector(receivedPlayerMovedLetterBlockNotification:) name:NEZ_ALETTERATION_NOTIFICATION_PLAYER_MOVE_LETTER_BLOCK object:nil];
	[_notificationCenter addObserver:self selector:@selector(receivedPlayerPlaceLetterBlockNotification:) name:NEZ_ALETTERATION_NOTIFICATION_PLAYER_PLACE_LETTER_BLOCK object:nil];
	[_notificationCenter addObserver:self selector:@selector(receivedPlayerRetireWordNotification:) name:NEZ_ALETTERATION_NOTIFICATION_PLAYER_RETIRE_WORD object:nil];
	[_notificationCenter addObserver:self selector:@selector(receivedPlayerStartTurnNotification:) name:NEZ_ALETTERATION_NOTIFICATION_PLAYER_START_TURN object:nil];
	[_notificationCenter addObserver:self selector:@selector(receivedPlayerEndTurnNotification:) name:NEZ_ALETTERATION_NOTIFICATION_PLAYER_END_TURN object:nil];
	[_notificationCenter addObserver:self selector:@selector(receivedPlayerGameOverNotification:) name:NEZ_ALETTERATION_NOTIFICATION_PLAYER_GAMEOVER object:nil];
	
//	NSString *word = @"hurt";
//	NSMutableArray *stringList = [NSMutableArray array];
//	[self loadResultsFromTheFreeDictionaryDotComOfWord:word withStringList:stringList andCompletionHandler:^{
//		if (stringList.count == 0) {
//			[self loadResultsFromDictionaryReferenceDotComOfWord:word withStringList:stringList andCompletionHandler:^{
//				if (stringList.count == 0) {
//					NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"No definition found."];
//					[string addAttribute:NSFontAttributeName value:[NSFont messageFontOfSize:25.0] range:NSMakeRange(0, 20)];
//					[stringList addObject:string];
//				}
//			}];
//		}
//	}];

	
//	[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_BIG_BOX withDuration:3.0 andCompletionBlock:nil];

	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		[_physics addNoMoveConstraintForNode:_gameTable.box withKey:NEZ_ALETTERATION_RIGID_BODY_CONSTRAINT_BIG_BOX_NO_MOVE];
	} DoneBlock:^{
		[self startGame];
	}];
}

-(void)startGame {
	[_gameTable setupNewGameForPlayerCount:NEZ_ALETTERATION_MAX_PLAYERS_PER_TABLE withGameController:self];

	[self doStartGameAnimationWithCompletionHandler:^{
//		[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER0_GAMEBOARD withDuration:3.0 andCompletionBlock:nil];
		[NezGCD dispatchBlock:^{
			for (NezAletterationPlayer *player in _gameTable.currentPlayerList) {
				[player startGame];
			}
		} afterSeconds:3.0];
	}];
}

-(void)startTurnForPlayer:(NezAletterationPlayer*)player {
	[player startTurn];
	if (player.currentLetterBlock) {
//		[player.currentLetterBlock addAnimatingHighlight];
		[self doMoveLetterBlockForPlayer:player toDefaultPositionAnimationWithCompletionHandler:^{
			[player turnStarted];
		}];
	}
}

-(void)moveCurrentLetterBlockForPlayer:(NezAletterationPlayer*)player toPosition:(GLKVector3)position andOrientation:(GLKQuaternion)orientation {
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		NezAletterationLetterBlock *letterBlock = player.currentLetterBlock;
		[letterBlock setRigidBodyPosition:position andOrientation:orientation];
	}];
}

-(void)placeCurrentLetterBlockForPlayer:(NezAletterationPlayer*)player onWordLine:(NezAletterationWordLine*)wordLine withCompletionHandler:(NezVoidBlock)completionHandler {
	if (player.currentLetterBlock && wordLine) {
		[player.gameState placeCurrentLetterOnLine:wordLine.index];
		
		NezAletterationLetterBlock *letterBlock = player.currentLetterBlock;
		GLKTransform t2 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(wordLine.nextLetterBlockTransform));
		if (completionHandler) {
			GLKTransform t1 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(letterBlock.transform));
			NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:t1.position P1Z:t1.position.z*0.5 P1T:0.15 P2Z:t1.position.z*0.25 P2T:0.85 P3:t2.position];
			
			[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
				[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:0.75 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
					float t = ani.newData[0];
					[letterBlock setRigidBodyPosition:[path positionAt:t] andOrientation:GLKQuaternionSlerp(t1.orientation, t2.orientation, t)];
				} DidStopBlock:^(NezAnimation *ani) {
					[NezGCD dispatchBlock:completionHandler];
				}];
			}];
		} else {
			[self moveCurrentLetterBlockForPlayer:player toPosition:t2.position andOrientation:t2.orientation];
		}
	}
}

-(void)retireWordForPlayer:(NezAletterationPlayer*)player fromWordLine:(NezAletterationWordLine*)wordLine withCompletionHandler:(NezVoidBlock)completionHandler {
	if (wordLine) {
		NezAletterationGameStateRetiredWord *gameStateRetiredWord = [player.gameState retireWordFromLine:wordLine.index];
		if (gameStateRetiredWord) {
			SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
			NSArray *letterBlockList = [wordLine removeBlocksInRange:gameStateRetiredWord.range];

			CATransform3D gbt = player.gameBoard.transform;
			CATransform3D rwt = [player.gameBoard.retiredWordBoard transformForNextWord];
			
			NezAletterationGameBoard *gameBoard = player.gameBoard;
			NezAletterationRetiredWord *retiredWord = [NezAletterationRetiredWord retiredWordWithGameStateRetiredWord:gameStateRetiredWord turnIndex:player.gameState.turn andLetterBlockList:letterBlockList];
			[gameBoard.retiredWordBoard addRetiredWord:retiredWord];
			
			for (int i=0; i<retiredWord.letterBlockList.count; i++) {
				[NezGCD dispatchBlock:^{
					[_graphics addFireworksEmitterAt:SCNVector3Make(randomVariation(gameBoard.position.x, 5.0), randomVariation(gameBoard.position.y, 5.0), randomVariation(70.0*letterBlockSize.z, 1.5)) withEmitterNode:nil];
				} afterSeconds:0.5*i];
			}

			if (completionHandler) {
				float xOffset = -(((float)(letterBlockList.count-1))*0.5*letterBlockSize.x);
				__block int lettersMoved = 0;
				NSString *word = retiredWord.word;
				[NezGCD dispatchBlock:^{
					float i = 0;
					for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
						[self moveLetterBlock:letterBlock withGameBoardTransform:gbt RetiredWordTransform:rwt Offset:GLKVector3Make((i*letterBlockSize.x), 2.0*letterBlockSize.y, 50.0*letterBlockSize.z) xOffset:xOffset withCompletionHandler:^{
							lettersMoved++;
							if (lettersMoved == letterBlockList.count) {
								[NezGCD dispatchBlock:^{
									if (completionHandler) {
										NSMutableArray *stringList = [NSMutableArray array];
										[self loadResultsFromTheFreeDictionaryDotComOfWord:word withStringList:stringList andCompletionHandler:^{
											if (stringList.count == 0) {
												[self loadResultsFromDictionaryReferenceDotComOfWord:word withStringList:stringList andCompletionHandler:^{
													if (stringList.count == 0) {
														NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"No definition found."];
														[string addAttribute:NSFontAttributeName value:[NSFont messageFontOfSize:25.0] range:NSMakeRange(0, 20)];
														[stringList addObject:string];
													}
													[retiredWord setDefinition:[NezAletterationDefinition definitionWithAttributedStringList:stringList]];
												}];
											} else {
												[retiredWord setDefinition:[NezAletterationDefinition definitionWithAttributedStringList:stringList]];
											}
										}];
										completionHandler();
									}
								}];
							}
						}];
						i += 1.0;
					}
				}];
			} else {
				float i = 0;
				for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
					GLKTransform t2 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4Translate(GLKMatrix4FromCATransform3D(rwt), (i*letterBlockSize.x), 0.0, 0.0));
					[letterBlock setRigidBodyPosition:t2.position andOrientation:t2.orientation];
					i += 1.0;
				}
			}
		}
	}
}

-(void)loadResultsFromTheFreeDictionaryDotComOfWord:(NSString*)word withStringList:(NSMutableArray*)stringList andCompletionHandler:(NezVoidBlock)completionHandler {
	[self sendGetRequestForURL:[NSString stringWithFormat:@"http://www.thefreedictionary.com/%@", word] withCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
			if (httpResponse.statusCode != 200) {
				//Error
			} else {
				[NezGCD runLowPriorityWithWorkBlock:^{
					NezXML *dictionaryParser = [NezXML htmlDocWithData:data];
					[dictionaryParser recursivelyDeleteAllElementsWithName:@"script"];
					[dictionaryParser deleteNodesWithXPathQuery:@"//div[contains(concat(' ', @class, ' '), ' brand_copy ')]"];
					NSArray *ulElements = [dictionaryParser performXPathQuery:@"/html/body/table[@id='ContentTable']/tr/td/div[@id='MainTxt']/ul"];
					for (NezXMLElement *ul in ulElements) {
						[ul.prev deleteElement];
						[ul deleteElement];
					}
					[dictionaryParser deleteNodesWithXPathQuery:@"/html/body/table[@id='ContentTable']/tr/td/div[@id='MainTxt']/div[@id='Thesaurus']"];
					[dictionaryParser deleteNodesWithXPathQuery:@"/html/body/table[@id='ContentTable']/tr/td/div[@id='MainTxt']/div[@id='Translations']"];
					
					NSArray *picElements = [dictionaryParser performXPathQuery:@"//div[contains(concat(' ', @class, ' '), ' pic ')]"];
					for (NezXMLElement *picElement in picElements) {
						[picElement.parent deleteElement];
					}
					NSArray *hrElements = [dictionaryParser performXPathQuery:@"/html/body/table[@id='ContentTable']/tr/td/div[@id='MainTxt']/hr"];
					if (hrElements.count > 0) {
						for (NezXMLElement *hr in hrElements) {
							NSUInteger elementsAdded = 0;
							
							NezXMLElement *td = [NezXMLElement elementWithXMLNodeName:@"td"];
							
							for (NezXMLElement *next = hr.next; next; ) {
								NezXMLElement *currentNode = next;
								next = next.next;
								if ([currentNode.name isEqualToString:@"table"] || [currentNode.name isEqualToString:@"hr"]) {
									break;
								}
								elementsAdded++;
								[td addChild:currentNode];
							}
							if (elementsAdded == 0) {
								[td deleteElement];
							} else {
								NezXMLElement *table = [NezXMLElement elementWithXMLNodeName:@"table"];
								NezXMLElement *tr = [NezXMLElement elementWithXMLNodeName:@"tr"];
								[hr addPrevSibling:table];
								[table addChild:tr];
								[tr addChild:td];
							}
							[hr deleteElement];
						}
						NSArray *tableElements = [dictionaryParser performXPathQuery:@"/html/body/table[@id='ContentTable']/tr/td/div[@id='MainTxt']/table"];
						[self htmlElements:tableElements toAttributedStrings:stringList];
					} else {
						NSArray *mainTxt = [dictionaryParser performXPathQuery:@"/html/body/table[@id='ContentTable']/tr/td/div[@id='MainTxt']"];
						[self htmlElements:mainTxt toAttributedStrings:stringList];
					}
				} DoneBlock:completionHandler];
			}
		}
	}];
}

-(void)loadResultsFromDictionaryReferenceDotComOfWord:(NSString*)word withStringList:(NSMutableArray*)stringList andCompletionHandler:(NezVoidBlock)completionHandler {
	[self sendGetRequestForURL:[NSString stringWithFormat:@"http://dictionary.reference.com/browse/%@", word] withCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
			if (httpResponse.statusCode != 200) {
				//Error
			} else {
				[NezGCD runLowPriorityWithWorkBlock:^{
					NezXML *dictionaryParser = [NezXML htmlDocWithData:data];
					[dictionaryParser recursivelyDeleteAllElementsWithName:@"script"];
					[dictionaryParser recursivelyDeleteAllElementsWithName:@"hr"];
					[dictionaryParser recursivelyDeleteAllElementsWithName:@"embed"];

					NSArray *defElements = [dictionaryParser performXPathQuery:@"/html/body/div/div/div/center/div/div/div/div/div/div/div/div[@class='lunatext results_content']/table"];
					[self htmlElements:defElements toAttributedStrings:stringList];
				} DoneBlock:completionHandler];
			}
		}
	}];
}

-(void)moveLetterBlock:(NezAletterationLetterBlock*)letterBlock withGameBoardTransform:(CATransform3D)gbt RetiredWordTransform:(CATransform3D)rwt Offset:(GLKVector3)offset xOffset:(float)xOffset withCompletionHandler:(NezVoidBlock)completionHandler {
	GLKTransform t1 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(letterBlock.transform));
	GLKTransform t2 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4Translate(GLKMatrix4FromCATransform3D(gbt), xOffset+offset.x, offset.y, offset.z));
//	NezNodeStarStreamerEmitter *starStreamer = [_graphics addStarStreamEmitterAt:SCNVector3Make(0.0, 0.0, 0.0) withEmitterNode:letterBlock];
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:1.5 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
			float t = ani.newData[0];
			[letterBlock setRigidBodyPosition:GLKVector3Lerp(t1.position, t2.position, t) andOrientation:GLKQuaternionSlerp(t1.orientation, t2.orientation, t)];
		} DidStopBlock:^(NezAnimation *ani) {
			GLKTransform t1 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(letterBlock.transform));
			GLKTransform t2 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4Translate(GLKMatrix4FromCATransform3D(rwt), offset.x, 0.0, 0.0));
			[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:2.5 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
				float t = ani.newData[0];
				[letterBlock setRigidBodyPosition:GLKVector3Lerp(t1.position, t2.position, t) andOrientation:GLKQuaternionSlerp(t1.orientation, t2.orientation, t)];
			} DidStopBlock:^(NezAnimation *ani) {
				[NezGCD dispatchBlock:^{
//					[starStreamer stopSpawing];
					if (completionHandler) {
						completionHandler();
					}
				}];
			}];
		}];
	}];
}

-(void)endTurnForPlayer:(NezAletterationPlayer*)player {
//	[player.currentLetterBlock removeAnimatingHighlight];
	[player endTurnWithCompletionHandler:^(NSArray *letterBlockSetupContainerList){
		if (letterBlockSetupContainerList) {
			[SCNTransaction begin];
			[SCNTransaction setAnimationDuration:0.5];
			for (NezAletterationLetterBlockSetupContainer *container in letterBlockSetupContainerList) {
				container.letterBlock.color = container.color;
			}
			[SCNTransaction commit];
			
			[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
				[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
					float t = ani.newData[0];
					for (NezAletterationLetterBlockSetupContainer *container in letterBlockSetupContainerList) {
						[container.letterBlock setRigidBodyPosition:GLKVector3Lerp(container.originalPosition, container.position, t) andOrientation:container.orientation];
					}
				} DidStopBlock:^(NezAnimation *ani) {
					[NezGCD dispatchBlock:^{
						[player turnEnded];
					}];
				}];
			}];
		}
	}];
}

-(void)gameOverForPlayer:(NezAletterationPlayer*)player {
	[NezGCD dispatchBlock:^{
		for (NezAletterationPlayer *player in _gameTable.playerList) {
			if (!player.isGameOver) {
				NSLog(@"still not done");
				return;
			}
		}
		[self doGameOverAnimationWithCompletionHandler:^{
			[self startGame];
		}];
	}];
}

-(void)doMoveLetterBlockForPlayer:(NezAletterationPlayer*)player toDefaultPositionAnimationWithCompletionHandler:(NezVoidBlock)completionBlock {
	if (player.currentLetterBlock) {
		NezAletterationLetterBlock *letterBlock = player.currentLetterBlock;
		
		[letterBlock setKinematic];
		
		[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
			GLKTransform t1 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(letterBlock.transform));
			GLKTransform t2 = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(player.gameBoard.defaultLetterBlockTransform));
			NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:t1.position P1Z:t2.position.z*0.5 P1T:0.15 P2Z:t2.position.z*0.75 P2T:0.75 P3:t2.position];
			[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:0.75 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
				float t = ani.newData[0];
				[letterBlock setRigidBodyPosition:[path positionAt:t] andOrientation:GLKQuaternionSlerp(t1.orientation, t2.orientation, t)];
			} DidStopBlock:^(NezAnimation *ani) {
				[NezGCD dispatchBlock:completionBlock];
			}];
		}];
	}
}

-(void)doStartGameAnimationWithCompletionHandler:(NezVoidBlock)completionBlock {
	NezAletterationBox *bigLid = _gameTable.lid;
	
	SCNVector3 bigLidSize = bigLid.dimensions;
	
//	[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_FULL_OVERVIEW withDuration:6.0 andCompletionBlock:nil];
	
	[NezGCD dispatchBlock:^{
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:5.0];
		for (NezAletterationPlayer *player in _gameTable.playerList) {
			NezAletterationGameBoard *gameBoard = player.gameBoard;
			gameBoard.color = SCNVector3Make(randomFloat(), randomFloat(), randomFloat());
		}
		[SCNTransaction commit];
	}];
	[self resetAllObjectsWithDoneBlock:^{
		[bigLid setKinematic];
		
		[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
			GLKTransform bigLidTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(bigLid.transform));
			GLKTransform bigLidEndTransform = GLKTransformMakeWithPositionAndOrientation(GLKVector3Make(-bigLidSize.x*0.55, 0.0, bigLidSize.z), GLKQuaternionIdentity);
			NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:bigLidTransform.position P1Z:bigLidSize.z*3.0 P1T:0.0 P2Z:bigLidSize.z*3.0 P2T:1.0 P3:bigLidEndTransform.position];
			[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:2.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
				float t = ani.newData[0];
				[bigLid setRigidBodyPosition:[path positionAt:t] andOrientation:GLKQuaternionSlerp(bigLidTransform.orientation, bigLidEndTransform.orientation, t)];
			} DidStopBlock:^(NezAnimation *ani) {
				[bigLid setDynamic];
				
				__block int gameStartedCount = 0;
				for (int i=0; i<4; i++) {
					[self doStartingAnimationForPlayerIndex:i withCompletionHandler:^{
						gameStartedCount++;
						if (gameStartedCount == 4) {
							[NezGCD dispatchBlock:completionBlock];
						}
					}];
				}
			}];
		}];
	}];
}

-(void)doGameOverAnimationWithCompletionHandler:(NezVoidBlock)completionBlock {
	NezAletterationBox *bigBox = _gameTable.box;
	NezAletterationBox *bigLid = _gameTable.lid;

	SCNVector3 bigLidSize = bigLid.dimensions;

	__block int boxInBigBoxCount = 0;
	for (int i=0; i<4; i++) {
		[NezGCD runOnQueue:_dynamicsQueue afterSeconds:2.5 WithWorkBlock:^{
			[self doCleanupAnimationForPlayerIndex:i withCompletionHandler:^{
				boxInBigBoxCount++;
				if (boxInBigBoxCount == 4) {
//					[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_BIG_BOX withDuration:3.0 andCompletionBlock:nil];
					
					[bigLid setKinematic];
					
					GLKTransform bigLidTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(bigLid.transform));
					GLKTransform bigLidEndTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D([bigBox transformForLid:bigLid]));
					NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:bigLidTransform.position P1Z:bigLidSize.z*3.0 P1T:0.0 P2Z:bigLidSize.z*3.0 P2T:1.0 P3:bigLidEndTransform.position];
					[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:2.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
						float t = ani.newData[0];
						[bigLid setRigidBodyPosition:[path positionAt:t] andOrientation:GLKQuaternionSlerp(bigLidTransform.orientation, bigLidEndTransform.orientation, t)];
					} DidStopBlock:^(NezAnimation *ani) {
						[bigLid setDynamic];
						[NezGCD dispatchBlock:completionBlock];
					}];
				}
			}];
		}];
	}
}

-(void)doStartingAnimationForPlayerIndex:(NSInteger)playerIndex withCompletionHandler:(NezVoidBlock)completionBlock {
	NezAletterationPlayer *player = _gameTable.playerList[playerIndex];
	NezAletterationGameBoard *gameBoard = player.gameBoard;
	NSArray *letterBlockList = gameBoard.letterBlockList;

	NezAletterationBox *smallBox = gameBoard.box;
	NezAletterationBox *smallLid = gameBoard.lid;
	
	SCNVector3 smallHoverToPosition = smallLid.position;
	smallHoverToPosition.z += smallLid.dimensions.z*10.0;
	
	NezAletterationLetterBag letterBag = [NezAletterationGameState fullLetterBag];
	
	GLKQuaternion gameBoardOrientation = GLKQuaternionMakeWithMatrix4(GLKMatrix4FromCATransform3D(gameBoard.transform));
	
	SCNVector3 boxSize = smallBox.dimensions;
	SCNVector3 lidSize = smallLid.dimensions;
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];

	if (playerIndex == 0) {
//		[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER0_STARTING withDuration:3.0 andCompletionBlock:nil];
	}
	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		[smallBox setKinematic];
		[smallLid setKinematic];
		
		GLKTransform smallBoxTransform = smallBox.glkTransform;
		GLKVector3 raiseBoxToFinalPosition = SCNVector3ToGLKVector3([gameBoard convertPosition:SCNVector3Make(0.0, 0.0, boxSize.z*7.0) toNode:nil]);
		GLKTransform smallBoxInAirTransform = GLKTransformMakeWithPositionAndOrientation(raiseBoxToFinalPosition, gameBoardOrientation);
		NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:smallBoxTransform.position P1Z:boxSize.z*14.0 P1T:0.0 P2Z:boxSize.z*8.0 P2T:1.0 P3:smallBoxInAirTransform.position];
		[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:3.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
			float t = ani.newData[0];
			
			GLKTransform smallBoxCurrentTransform = GLKTransformMakeWithPositionAndOrientation([path positionAt:t], GLKQuaternionSlerp(smallBoxTransform.orientation, smallBoxInAirTransform.orientation, t));
			[smallBox setRigidBodyPosition:smallBoxCurrentTransform.position andOrientation:smallBoxCurrentTransform.orientation];
			
			GLKTransform smallLidTransform = [smallBox glkTransformForLid:smallLid withBoxGLKTransform:smallBoxCurrentTransform];
			[smallLid setRigidBodyPosition:smallLidTransform.position andOrientation:smallLidTransform.orientation];
		} DidStopBlock:^(NezAnimation *ani) {
			[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
				for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
					[letterBlock setRigidBodyTransform:[smallBox transformForLetterBlock:letterBlock]];
				}
			} DoneBlock:^{
				[NezGCD dispatchBlock:^{
					for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
						letterBlock.hidden = NO;
					}
				} afterMilliseconds:33];
				[NezGCD runOnQueue:_dynamicsQueue afterMilliseconds:100 WithWorkBlock:^{
					GLKTransform smallLidTransform = smallLid.glkTransform;
					GLKVector3 smallLidOffTransform = GLKVector3Add(smallLidTransform.position, GLKVector3Make(0.0, 0.0, lidSize.z*2.0));
					[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:0.75 EasingFunction:EASE_IN_QUAD UpdateBlock:^(NezAnimation *ani) {
						float t = ani.newData[0];
						[smallLid setRigidBodyPosition:GLKVector3Lerp(smallLidTransform.position, smallLidOffTransform, t) andOrientation:smallLidTransform.orientation];
					} DidStopBlock:^(NezAnimation *ani) {
						[smallLid setDynamic];
						GLKVector3 forceVector = GLKQuaternionRotateVector3(gameBoardOrientation, GLKVector3Make(0.0, smallLid.bodyMass*12.0, smallLid.bodyMass*10.0));
						GLKVector3 position = GLKQuaternionRotateVector3(gameBoardOrientation, GLKVector3Make(0.0, -lidSize.y*0.5, -lidSize.z*0.35));
						[smallLid applyImpulse:SCNVector3FromGLKVector3(forceVector) atRelativePosition:SCNVector3FromGLKVector3(position)];

						for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
							[letterBlock setDynamic];
							[letterBlock stopMotion];
						}
						GLKQuaternion flipOverOrientation = GLKQuaternionMultiply(smallBoxInAirTransform.orientation, GLKQuaternionMakeWithAngleAndAxis(-M_PI, 1.0, -0.4, 0.2));
						GLKVector3 flipOverLocation = GLKVector3Add(smallBoxInAirTransform.position, GLKQuaternionRotateVector3(flipOverOrientation, GLKVector3Make(0.0, 0.0, -boxSize.z*0.5)));
						[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:2.0 EasingFunction:EASE_OUT_BOUNCE UpdateBlock:^(NezAnimation *ani) {
							float t = ani.newData[0];
							GLKQuaternion orientation = GLKQuaternionSlerp(smallBoxInAirTransform.orientation, flipOverOrientation, t);
							[smallBox setRigidBodyPosition:GLKVector3Lerp(smallBoxInAirTransform.position, flipOverLocation, t) andOrientation:orientation];
						} DidStopBlock:^(NezAnimation *ani) {
							[smallBox setDynamic];
							GLKVector3 forceVector = GLKQuaternionRotateVector3(gameBoardOrientation, GLKVector3Make(0.0, smallBox.bodyMass*18.0, smallBox.bodyMass*2.0));
							GLKVector3 position = GLKQuaternionRotateVector3(gameBoardOrientation, GLKVector3Make(0.0, -boxSize.y*0.5, boxSize.z*0.5));
							[smallBox applyImpulse:SCNVector3FromGLKVector3(forceVector) atRelativePosition:SCNVector3FromGLKVector3(position)];
							
							for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
								__weak NezAletterationLetterStack *stack = [gameBoard stackForLetter:letterBlock.letter];
								GLKVector3 offset = GLKVector3Make(0.0, 0.0, (letterBlock.stackIndex+0.5)*1.5*letterBlockSize.x);
								[letterBlock hoverToNode:stack.letterBlockPlacementNode atOffset:offset andRelativeOrientation:gameBoardOrientation withZStartupTime:0.25*letterBlock.stackIndex completionDistance:0.5 andCompletionHandler:^{
									[stack push:letterBlock];
									if ([gameBoard allStacksHaveCount:letterBag]) {
										NSMutableArray *letterBlockAnimationList = [NSMutableArray array];
										for (NezAletterationLetterStack *stack in gameBoard.stackList) {
											[stack sort];
											
											GLKTransform stackTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D([stack.letterBlockPlacementNode convertTransform:stack.letterBlockPlacementNode.transform toNode:nil]));
											for (NezAletterationLetterBlock *lb in stack.letterBlockList) {
												stackTransform.position.z = (lb.stackIndex+0.5)*1.0*letterBlockSize.x;
												NezAletterationNodeAnimationContainer *c = [NezAletterationNodeAnimationContainer containerWithNode:lb Start:lb.glkTransform End:stackTransform];
												[letterBlockAnimationList addObject:c];
												[lb stopHovering];
												[lb setKinematic];
											}
										}
										[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:1.0 EasingFunction:EASE_IN_QUAD UpdateBlock:^(NezAnimation *ani) {
											float t = ani.newData[0];
											for (NezAletterationNodeAnimationContainer *c in letterBlockAnimationList ) {
												GLKVector3 pos = GLKVector3Lerp(c.startTransform.position, c.endTransform.position, t);
												GLKQuaternion orientation = GLKQuaternionSlerp(c.startTransform.orientation, c.endTransform.orientation, t);
												[c.node setRigidBodyPosition:pos andOrientation:orientation];
											}
										} DidStopBlock:^(NezAnimation *ani) {
											for (NezAletterationNodeAnimationContainer *c in letterBlockAnimationList ) {
												[c.node setDynamic];
												[c.node applyCentralImpulse:SCNVector3Make(0.0, 0.0, -3.0)];
											}
											[NezGCD dispatchBlock:completionBlock];
										}];
									}
								}];
							}
						}];
					}];
				}];
			}];
		}].delay = randomFloat()*0.25;
	}];
}

-(void)doCleanupAnimationForPlayerIndex:(NSInteger)playerIndex withCompletionHandler:(NezVoidBlock)completionBlock {
	NezAletterationPlayer *player = _gameTable.playerList[playerIndex];
	NezAletterationGameBoard *gameBoard = player.gameBoard;
	NSArray *letterBlockList = gameBoard.letterBlockList;
	
	NezAletterationBigBox *bigBox = _gameTable.box;
	NezAletterationBox *smallBox = gameBoard.box;
	NezAletterationBox *smallLid = gameBoard.lid;
	
	SCNVector3 boxSize = smallBox.dimensions;
	
	if (playerIndex == 0) {
//		[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER0_STARTING withDuration:3.0 andCompletionBlock:nil];
	}

	NezVoidBlock returnBoxBlock = ^{
		[smallLid stopHovering];
		[smallLid setKinematic];
		[smallBox setKinematic];
		
		GLKTransform startTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(smallLid.transform));
		GLKTransform endTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D([smallBox transformForLid:smallLid]));
		[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:1.25 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
			float t = ani.newData[0];
			[smallLid setRigidBodyPosition:GLKVector3Lerp(startTransform.position, endTransform.position, t) andOrientation:GLKQuaternionSlerp(startTransform.orientation, endTransform.orientation, t)];
		} DidStopBlock:^(NezAnimation *ani) {
			for (NezAletterationLetterBlock *letterBlock in letterBlockList) {
				letterBlock.hidden = YES;
			}
			GLKTransform smallBoxTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(smallBox.transform));
			GLKTransform smallBoxInsideBigBoxTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D([bigBox transformForSmallBox:smallBox andPlayerIndex:playerIndex]));
			NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:smallBoxTransform.position P1Z:boxSize.z*10.0 P1T:0.25 P2Z:boxSize.z*8.0 P2T:1.0 P3:smallBoxInsideBigBoxTransform.position];
			[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:3.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
				float t = ani.newData[0];
				
				GLKTransform smallBoxCurrentTransform = GLKTransformMakeWithPositionAndOrientation([path positionAt:t], GLKQuaternionSlerp(smallBoxTransform.orientation, smallBoxInsideBigBoxTransform.orientation, t));
				[smallBox setRigidBodyPosition:smallBoxCurrentTransform.position andOrientation:smallBoxCurrentTransform.orientation];

				GLKTransform smallLidTransform = [smallBox glkTransformForLid:smallLid withBoxGLKTransform:smallBoxCurrentTransform];
				[smallLid setRigidBodyPosition:smallLidTransform.position andOrientation:smallLidTransform.orientation];
			} DidStopBlock:^(NezAnimation *ani) {
				if (completionBlock) {
					[smallLid setDynamic];
					[smallBox setDynamic];
					[NezGCD dispatchBlock:completionBlock];
				}
			}];
		}];
	};
	
	__block int letterBlockInBoxCount = 0;
	__block BOOL lidIsInPlace = NO;
	[smallBox hoverToNode:gameBoard atOffset:GLKVector3Make(0.0, boxSize.y*0.6, bigBox.dimensions.z*3.5) andRelativeOrientation:GLKQuaternionIdentity withZStartupTime:1.5 completionDistance:15.0 andCompletionHandler:^{
		[smallBox hoverToNode:gameBoard atOffset:GLKVector3Make(0.0, boxSize.y*0.6, boxSize.z*0.5) andRelativeOrientation:GLKQuaternionIdentity withZStartupTime:0.0 completionDistance:5.0 andCompletionHandler:^{
			[smallBox stopHovering];
			
			[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
				for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
					[letterBlock setDynamic];
					GLKTransform lbt = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D([smallBox relativeTransformForLetterBlock:letterBlock]));
					GLKVector3 pos = GLKVector3Make(0.0, 0.0, boxSize.z*3.5);
					[letterBlock hoverToNode:smallBox atOffset:pos andRelativeOrientation:lbt.orientation withCompletionDistance:12.5 completionTimeout:5.0 andCompletionHandler:^{
						GLKVector3 pos2 = GLKVector3Make(0.0, 0.0, boxSize.z*2.0);
						[letterBlock hoverToNode:smallBox atOffset:pos2 andRelativeOrientation:lbt.orientation withCompletionDistance:6.5 completionTimeout:10.0 andCompletionHandler:^{
							[letterBlock stopHovering];
							[letterBlock setKinematic];
							GLKTransform startTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D(letterBlock.transform));
							GLKTransform endTransform = GLKTransformMakeWithGLKMatrix4(GLKMatrix4FromCATransform3D([smallBox transformForLetterBlock:letterBlock]));
							NezPathCubicBezier3d *path = [NezPathCubicBezier3d bezierWithControlPointsP0:startTransform.position P1Z:startTransform.position.z P1T:0.75 P2Z:startTransform.position.z*0.5 P2T:1.0 P3:endTransform.position];
							[_kinematicsAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:GLKVector3Distance(startTransform.position, endTransform.position)*0.075 EasingFunction:EASE_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
								float t = ani.newData[0];
								GLKVector3 pos = [path positionAt:t];
								[letterBlock setRigidBodyPosition:pos andOrientation:GLKQuaternionSlerp(startTransform.orientation, endTransform.orientation, t)];
							} DidStopBlock:^(NezAnimation *ani) {
								letterBlockInBoxCount++;
								if (lidIsInPlace && letterBlockInBoxCount == [NezAletterationGameState letterCount]) {
									returnBoxBlock();
								}
							}];
						}];
					}];
				}
			}];
		}];
		[smallLid hoverToNode:smallBox atOffset:GLKVector3Make(0.0, 0.0, boxSize.z*7.0) andRelativeOrientation:GLKQuaternionIdentity withCompletionDistance:5.0 completionTimeout:12.0 andCompletionHandler:^{
			lidIsInPlace = YES;
			if (letterBlockInBoxCount == [NezAletterationGameState letterCount]) {
				returnBoxBlock();
			}
		}];
	}];
}

-(void)resetAllObjectsWithDoneBlock:(NezVoidBlock)doneBlock {
	NezAletterationBigBox *bigBox = _gameTable.box;
	NezAletterationBox *bigLid = _gameTable.lid;

	[NezGCD runOnQueue:_dynamicsQueue WithWorkBlock:^{
		[bigBox setKinematic];
		[bigLid setKinematic];
		
		for (NezAletterationPlayer *player in _gameTable.playerList) {
			NezAletterationGameBoard *gameBoard = player.gameBoard;
			
			[gameBoard resetAllLetterBlockContainers];
			
			NezAletterationBox *smallBox = gameBoard.box;
			NezAletterationBox *smallLid = gameBoard.lid;

			[smallBox setKinematic];
			[smallLid setKinematic];
			
			for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
				[letterBlock setKinematic];
			}
		}
	} DoneBlock:^{
		[NezGCD runOnQueue:_dynamicsQueue afterMilliseconds:35 WithWorkBlock:^{
			[bigBox setRigidBodyTransform:_gameTable.boxTransform];
			bigLid.transform = [bigBox transformForLid:bigLid];
			
			for (NezAletterationPlayer *player in _gameTable.playerList) {
				NezAletterationGameBoard *gameBoard = player.gameBoard;
				
				NezAletterationBox *smallBox = gameBoard.box;
				[smallBox setRigidBodyTransform:[bigBox transformForSmallBox:smallBox andPlayerIndex:player.index]];

				NezAletterationBox *smallLid = gameBoard.lid;
				[smallLid setRigidBodyTransform:[smallBox transformForLid:smallLid]];

				for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
					[letterBlock setRigidBodyTransform:[smallBox transformForLetterBlock:letterBlock]];
				}
			}

		} DoneBlock:^{
			[NezGCD runOnQueue:_dynamicsQueue afterMilliseconds:35 WithWorkBlock:^{
				[bigBox setDynamic];
				[bigLid setDynamic];
				
				for (NezAletterationPlayer *player in _gameTable.playerList) {
					NezAletterationGameBoard *gameBoard = player.gameBoard;
					
					NezAletterationBox *smallBox = gameBoard.box;
					NezAletterationBox *smallLid = gameBoard.lid;
					
					[smallBox setDynamic];
					[smallLid setDynamic];
					
					for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
//						[letterBlock setDynamic];
						letterBlock.hidden = YES;
					}
				}
				[NezGCD dispatchBlock:doneBlock];
			}];
		}];
	}];
}

-(void)controllerRemoved {
	[_physics removeConstraintForKey:NEZ_ALETTERATION_RIGID_BODY_CONSTRAINT_BIG_BOX_NO_MOVE];
	[_notificationCenter removeObserver:self];
}

-(void)keyDown:(NSEvent *)theEvent {
	_animationRandomCamera = NO;
}

-(void)keyUp:(NSEvent *)theEvent {
	NSLog(@"%d %@", theEvent.keyCode, theEvent.characters);
	switch (theEvent.keyCode) {
		case 18:
			if (theEvent.modifierFlags & NSShiftKeyMask) {
				[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER0_STARTING withDuration:3.0 andCompletionBlock:nil];
			} else {
				[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER0_GAMEBOARD withDuration:3.0 andCompletionBlock:nil];
			}
			break;
		case 19:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER1_GAMEBOARD withDuration:3.0 andCompletionBlock:nil];
			break;
		case 20:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER2_GAMEBOARD withDuration:3.0 andCompletionBlock:nil];
			break;
		case 21:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER3_GAMEBOARD withDuration:3.0 andCompletionBlock:nil];
			break;
		case 83:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER0_RETIRED_WORDS withDuration:3.0 andCompletionBlock:nil];
			break;
		case 84:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER1_RETIRED_WORDS withDuration:3.0 andCompletionBlock:nil];
			break;
		case 85:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER2_RETIRED_WORDS withDuration:3.0 andCompletionBlock:nil];
			break;
		case 86:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_PLAYER3_RETIRED_WORDS withDuration:3.0 andCompletionBlock:nil];
			break;
		case 3:
			[self.nezSCNAletterationView animateToCameraForName:NEZ_ALETTERATION_CAMERA_FULL_OVERVIEW withDuration:3.0 andCompletionBlock:nil];
			break;
		case 15:
			_animationRandomCamera = YES;
			[self animateToRandomCamera];
			break;
		default:
			break;
	}
}

-(void)nothingHitForEvent:(NSEvent*)event {
	if (event.type == NSLeftMouseUp) {
		for (NezAletterationPlayer *player in _gameTable.playerList) {
			NezAletterationGameBoard *gameBoard = player.gameBoard;
			if (gameBoard.retiredWordBoard.definitionBubble.isShowing) {
				[gameBoard.retiredWordBoard.definitionBubble reset];
			}
		}
	}
}

-(void)animateToRandomCamera {
	[self.nezSCNAletterationView animateToRandomCameraWithCompletionHandler:^{
		if (_animationRandomCamera) {
			[self animateToRandomCamera];
		}
	}];
}

-(void)sendGetRequestForURL:(NSString*)url withCompletionHandler:(NezURLResponseHandler)responseHandler {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:[NSURL URLWithString:url]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:responseHandler];
}

-(void)receivedPlayerMovedLetterBlockNotification:(NSNotification*)notification {
	NezAletterationPlayerNotificationMoveLetterBlock *movedNotification = notification.object;
	NezAletterationPlayer *player = _gameTable.currentPlayerList[movedNotification.playerIndex];
	[self moveCurrentLetterBlockForPlayer:player toPosition:movedNotification.position andOrientation:movedNotification.orientation];
}

-(void)receivedPlayerPlaceLetterBlockNotification:(NSNotification*)notification {
	NezAletterationPlayerNotificationLine *placeNotification = notification.object;
	NezAletterationPlayer *player = _gameTable.currentPlayerList[placeNotification.playerIndex];
	NezAletterationWordLine *wordLine = [player.gameBoard wordLineForIndex:placeNotification.lineIndex];
	[self placeCurrentLetterBlockForPlayer:player onWordLine:wordLine withCompletionHandler:^{
		[player blockPlaced];
	}];
}

-(void)receivedPlayerRetireWordNotification:(NSNotification*)notification {
	NezAletterationPlayerNotificationLine *placeNotification = notification.object;
	NezAletterationPlayer *player = _gameTable.currentPlayerList[placeNotification.playerIndex];
	NezAletterationWordLine *wordLine = [player.gameBoard wordLineForIndex:placeNotification.lineIndex];
	[self retireWordForPlayer:player fromWordLine:wordLine withCompletionHandler:^{
		[player turnContinues];
	}];
}

-(void)receivedPlayerStartTurnNotification:(NSNotification*)notification {
	NezAletterationPlayerNotification *startTurnNotification = notification.object;
	NezAletterationPlayer *player = _gameTable.currentPlayerList[startTurnNotification.playerIndex];
	[self startTurnForPlayer:player];
}

-(void)receivedPlayerEndTurnNotification:(NSNotification*)notification {
	NezAletterationPlayerNotification *endTurnNotification = notification.object;
	NezAletterationPlayer *player = _gameTable.currentPlayerList[endTurnNotification.playerIndex];
	[self endTurnForPlayer:player];
}

-(void)receivedPlayerGameOverNotification:(NSNotification*)notification {
	NezAletterationPlayerNotification *gameOverNotification = notification.object;
	NezAletterationPlayer *player = _gameTable.currentPlayerList[gameOverNotification.playerIndex];
	[self gameOverForPlayer:player];
}

@end
