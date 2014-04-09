//
//  NezGameCenter.m
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-13.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//
#import "NezGameCenter.h"

@interface NezGameCenter () {
	NSMutableDictionary *_opponentsDict;
}

@end

@implementation NezGameCenter

static NezGameCenter *gGameCenterInstance = nil;

+(void)initialize {
	@synchronized (self) {
		if (!gGameCenterInstance) {
			gGameCenterInstance = [[NezGameCenter alloc] init];
		}
	}
}

+(NezGameCenter*)sharedInstance {
	return gGameCenterInstance;
}

-(id)init {
    if ((self = [super init])) {
    }
    return self;
}

-(void)authenticateLocalUserWithHandler:(NezGameCenterAuthenticationBlock)handler {
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.authenticated == NO) {
		localPlayer.authenticateHandler = handler;
    }
}

-(void)lookupOpponentsWithCompletionHandler:(NezGameCenterLookupPlayersBlock)completionHandler {
	_opponentsDict = [NSMutableDictionary dictionaryWithCapacity:4];

	GKMatch *match = self.match;
	
	[GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
		if (error != nil) {
			NSLog(@"Error retrieving player info: %@", error.localizedDescription);
			_matchStarted = NO;
			[self.delegate matchEnded];
		} else {
			// Populate players dict
			for (GKPlayer *player in players) {
				_opponentsDict[player.playerID] = player;
			}
		}
		completionHandler(players, error);
	}];
}

-(NSArray*)getOpponentPlayerIdList {
	return self.match.playerIDs;
}

-(NSString*)getLocalPlayerId {
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	return localPlayer.playerID;
}

-(GKLocalPlayer*)getLocalPlayer {
	return [GKLocalPlayer localPlayer];
}

-(void)loadPhotoForLocalPlayerWithCompletionHandler:(NezGameCenterLoadImageBlock)completionHandler {
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	[self loadPhotoForPlayer:localPlayer withCompletionHandler:completionHandler];
}

-(void)loadPhotoForOpponentPlayerId:(NSString*)playerId withCompletionHandler:(NezGameCenterLoadImageBlock)completionHandler {
	GKPlayer *player = _opponentsDict[playerId];
	[self loadPhotoForPlayer:player withCompletionHandler:completionHandler];
}

-(void)loadPhotoForPlayer:(GKPlayer*)player withCompletionHandler:(NezGameCenterLoadImageBlock)completionHandler {
	if (player == nil) {
		completionHandler(nil, [[NSError alloc] init]);
	} else {
		[player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:completionHandler];
	}
}

-(void)sendDataReliable:(NSData*)data withDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock {
	NSError *error;
	BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
	if (dataSentBlock) {
		dataSentBlock(success, error);
	}
}

-(void)sendDataUnreliable:(NSData*)data withDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock {
	NSError *error;
	BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataUnreliable error:&error];
	if (dataSentBlock) {
		dataSentBlock(success, error);
	}
}

-(void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController*)viewController delegate:(id<NezGameCenterDelegate>)delegate {
	_matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    self.delegate = delegate;
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{}];
	
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
	
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
	
    [self.presentingViewController presentViewController:mmvc animated:YES completion:^{}];
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
-(void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		[self.delegate matchmakerViewControllerWasCancelled];
	}];
}

// Matchmaking has failed with an error
-(void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		[self.delegate matchmakerViewControllerDidFailWithError:error];
	}];
}

// A peer-to-peer match has been found, the game should start
-(void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
	self.match = match;
	self.match.delegate = self;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		if (!_matchStarted && match.expectedPlayerCount == 0) {
			// Notify delegate match can begin
            _matchStarted = YES;
            [self.delegate matchStarted];
		}
	}];
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (self.match != match) return;
	
    [self.delegate match:match didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
-(void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (self.match != match) return;
	
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
			 [self.delegate match:match connectionfromPlayer:playerID];
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            [self.delegate match:match disconnectionfromPlayer:playerID];
            break;
    }
}

// The match was unable to connect with the player due to an error.
-(void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    if (self.match != match) return;
	
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [self.delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
-(void)match:(GKMatch *)match didFailWithError:(NSError *)error {
	
    if (self.match != match) return;
	
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [self.delegate matchEnded];
}

@end
