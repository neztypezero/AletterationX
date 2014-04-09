//
//  NezAletterationGameTable.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/11.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameTable.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationPlayerAI.h"
#import "NezAnimator.h"

@implementation NezAletterationGameTable {
	NSMutableArray *_playerList;
	NSArray *_currentGamePlayerList;
}

+(instancetype)table {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		SCNVector3 bigBoxColor = SCNVector3Make(1.0, 0.95, 0.90);

		_box = [NezAletterationGraphics newBigBox];
		_box.transform = self.boxTransform;
		_box.color = bigBoxColor;
		_lid = [NezAletterationGraphics newBigLid];
		_lid.color = bigBoxColor;
		_lid.transform = [_box transformForLid:_lid];

//		_box.opacity = 0.25;
//		_lid.opacity = 0.25;

		_playerList = [NSMutableArray array];
		
		SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
		GLKVector2 positions[4] = {
			{ 0, -1},
			{ 1,  0},
			{ 0,  1},
			{-1,  0},
		};
		for (NSUInteger i=0; i<NEZ_ALETTERATION_MAX_PLAYERS_PER_TABLE; i++) {
			NezAletterationPlayer *player = [NezAletterationPlayerAI player];
			NSLog(@"%@", player);
			player.index = i;
			
			NezAletterationGameBoard *gameBoard = player.gameBoard;
			gameBoard.transform = CATransform3DMakeTranslation(positions[i].x*(letterBlockSize.x*22.0), positions[i].y*(letterBlockSize.y*22.0), 0.0);
			gameBoard.transform = CATransform3DRotate(gameBoard.transform, (M_PI/2.0)*i, 0.0, 0.0, 1.0);
			
			gameBoard.box.transform = [_box transformForSmallBox:gameBoard.box andPlayerIndex:player.index];
			gameBoard.lid.transform = [gameBoard.box transformForLid:gameBoard.lid];
			
			for (NezAletterationLetterBlock *letterBlock in gameBoard.letterBlockList) {
				letterBlock.transform = [gameBoard.box transformForLetterBlock:letterBlock];
			}
			
//			gameBoard.box.opacity = 0.25;
//			gameBoard.lid.opacity = 0.25;
			
			[_playerList addObject:player];
		}
		
		_currentGamePlayerList = @[];
	}
	return self;
}

-(NSArray*)playerList {
	return _playerList;
}

-(NSUInteger)playerCount {
	return _playerList.count;
}

-(NSArray*)currentPlayerList {
	return _currentGamePlayerList;
}

-(NSUInteger)currentPlayerCount {
	return _currentGamePlayerList.count;
}

-(CATransform3D)boxTransform {
	SCNVector3 boxSize = _box.dimensions;
	return CATransform3DMakeTranslation(boxSize.x*0.52, 0.0, boxSize.z*0.5);
}

-(void)setupNewGameForPlayerCount:(NSUInteger)playerCount withGameController:(NezAletterationGameController*)gameController {
	if (playerCount < 1) {
		playerCount = 1;
	} else if (playerCount > NEZ_ALETTERATION_MAX_PLAYERS_PER_TABLE) {
		playerCount = NEZ_ALETTERATION_MAX_PLAYERS_PER_TABLE;
	}
	_currentGamePlayerList = [NSArray arrayWithArray:[_playerList subarrayWithRange:NSMakeRange(0, playerCount)]];
	
	char letterList[[NezAletterationGameState letterCount]+1];
	[NezAletterationGameState randomizedLetterList:letterList];
	
	for (NezAletterationPlayer *player in _currentGamePlayerList) {
		player.gameController = gameController;
		player.gameState = [NezAletterationGameState gameStateWithLetterList:letterList];
	}
}

-(NezAletterationPlayer*)playerForIndex:(NSUInteger)playerIndex {
	return _playerList[playerIndex];
}

@end
