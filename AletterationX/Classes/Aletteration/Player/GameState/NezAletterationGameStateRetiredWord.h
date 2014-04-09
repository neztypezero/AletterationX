//
//  NezAletterationGameStateRetiredWord.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@interface NezAletterationGameStateRetiredWord : NSObject<NSCoding>

@property int64_t lineIndex;
@property NSRange range;
@property NSArray *stateList;

@end
