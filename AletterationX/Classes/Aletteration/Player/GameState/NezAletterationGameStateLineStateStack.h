//
//  NezAletterationGameStateLineStateStack.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@class NezAletterationGameStateLineState;

@interface NezAletterationGameStateLineStateStack : NSObject<NSCoding> {
	NSMutableArray *_lineStateList;
}

@property (readonly, getter = getCount) NSInteger count;
@property (readonly, getter = getTopLineState) NezAletterationGameStateLineState *topLineState;
@property (readonly, getter = getStateList) NSArray *stateList;

-(void)pushLineState:(NezAletterationGameStateLineState*)lineState;
-(void)pushUpdatedState:(NezAletterationGameStateLineState*)lineState;
-(void)pushLineStateList:(NSArray*)lineStateList;

-(void)removeTopLineState;
-(void)removeLineStatesForTurn:(NSInteger)turn;
-(NSArray*)removeStatesInRange:(NSRange)range;

@end
