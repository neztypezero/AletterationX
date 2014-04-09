//
//  NezAletterationGameStateTurn.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@interface NezAletterationGameStateTurn : NSObject<NSCoding>

@property int64_t temporaryLineIndex;
@property int64_t lineIndex;
@property (nonatomic, strong) NSMutableArray *retiredWordList;

+(NezAletterationGameStateTurn*)turn;

@end
