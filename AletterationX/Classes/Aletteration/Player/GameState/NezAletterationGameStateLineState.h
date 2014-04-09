//
//  NezAletterationWordState.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@class NezAletterationGameStateLineState;

@interface NezAletterationGameStateLineState : NSObject<NSCoding>

@property int64_t state;
@property int64_t index;
@property int64_t length;
@property int64_t turn;

+(NezAletterationGameStateLineState*)lineState;
+(NezAletterationGameStateLineState*)lineStateCopy:(NezAletterationGameStateLineState*)lineState;
+(NezAletterationGameStateLineState*)nextLineState:(NezAletterationGameStateLineState*)lineState;
+(NezAletterationGameStateLineState*)lineStateWithState:(int64_t)state index:(int64_t)index length:(int64_t)length andTurn:(int64_t)turn;

-(BOOL)isEqual:(NezAletterationGameStateLineState*)lineState;

@end
