//
//  NezAletterationPlayerAI.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/12.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "NezAletterationPlayerAI.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameStateLineState.h"
#import "NezAletterationGameStateLineStateStack.h"
#import "NezAletterationSQLiteDictionary.h"
#import "NezRandom.h"
#import "NezAletterationGameController.h"
#import "NezGLKUtil.h"
#import "NezPathCubicBezier3d.h"
#import "NezAletterationGeometry.h"
#import "NezAnimator.h"
#import "NezAletterationPlayerNotifications.h"
#import "NezAletterationGameStateLineState.h"

@implementation NezAletterationPlayerAI

-(int)bonusLetterCountFromWord:(char*)word {
	int count = 0;
	if (strchr(word, 'j')) { count++; }
	if (strchr(word, 'q')) { count++; }
	if (strchr(word, 'x')) { count++; }
	if (strchr(word, 'z')) { count++; }
	return count;
}

-(void)turnStarted {
	[NezGCD runLowPriorityWithWorkBlock:^{
		for (int64_t i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
			NezAletterationGameStateLineState *lineState = [self.gameState currentLineStateForIndex:i];
			switch (lineState.state) {
				case NEZ_ALETTERATION_INPUT_ISWORD: {
					NezAletterationPlayerNotificationLine *notification = [NezAletterationPlayerNotificationLine notificationWithPlayerIndex:self.index andLineIndex:i];
					[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_RETIRE_WORD object:notification userInfo:nil];
					return;
				}
			}
		}

		int64_t bestRankIndex = 0;
		double bestRank = 0.0;
		NezAletterationLetterBag letterBag = self.gameState.currentLetterBagCopy;
		letterBag.count[self.gameState.currentLetter-'a']--;
		
		for (int64_t i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
			char word[128];
			if ([self.gameState currentLineStateForIndex:i].state == NEZ_ALETTERATION_INPUT_ISNOTHING) {
				word[0] = self.gameState.currentLetter;
				word[1] = '\0';
			} else {
				[self.gameState copyFromLine:i intoLine:word];
			}
			NezAletterationDictionaryCounts counts = [self.gameState countsForLine:word andLetterCounts:letterBag];
			
			int64_t pc = counts.prefixCount;
			int64_t letterCount = [self.gameState getLineLengthForLineIndex:i];
			int64_t ll = letterCount+1+[self bonusLetterCountFromWord:word];
			
			int64_t bpc = pc>0?1:0;
			
			int64_t rll = (ll*ll)*randomFloatBetween(10000, 15000);
			int64_t rpc = pc*randomFloatBetween(10, 15);
			
			double rank = (rll*bpc+rpc);
			if (rank < ll) {
				rank = 1.0/(double)ll;
			}
			if (rank > bestRank) {
				bestRank = rank;
				bestRankIndex = i;
			}
		}
		if (bestRank < 10.0) {
			for (int64_t i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
				NezAletterationGameStateLineState *lineState = [self.gameState currentLineStateForIndex:i];
				switch (lineState.state) {
					case NEZ_ALETTERATION_INPUT_ISBOTH: {
						NezAletterationPlayerNotificationLine *notification = [NezAletterationPlayerNotificationLine notificationWithPlayerIndex:self.index andLineIndex:i];
						[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_RETIRE_WORD object:notification userInfo:nil];
						return;
					}
				}
			}
		}
		NezAletterationPlayerNotificationLine *notification = [NezAletterationPlayerNotificationLine notificationWithPlayerIndex:self.index andLineIndex:bestRankIndex];
		[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_PLACE_LETTER_BLOCK object:notification userInfo:nil];
	}];
}

-(void)retireWord {
	for (int64_t i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
		NezAletterationGameStateLineState *lineState = [self.gameState currentLineStateForIndex:i];
		switch (lineState.state) {
			case NEZ_ALETTERATION_INPUT_ISWORD: case NEZ_ALETTERATION_INPUT_ISBOTH: {
				NezAletterationPlayerNotificationLine *notification = [NezAletterationPlayerNotificationLine notificationWithPlayerIndex:self.index andLineIndex:i];
				[self.gameController.notificationCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PLAYER_RETIRE_WORD object:notification userInfo:nil];
				return;
			}
		}
	}
}

@end
