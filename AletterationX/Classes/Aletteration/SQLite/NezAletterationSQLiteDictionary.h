//
//  NezSQLiteDictionary.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

typedef struct NezAletterationDictionaryCounts {
	int64_t prefixCount;
	int64_t wordCount;
} NezAletterationDictionaryCounts;

@interface NezAletterationSQLiteDictionary : NSObject

+(NezAletterationDictionaryCounts)getCountsWithInput:(char*)inputString LetterCounts:(int*)letterCounter;
+(int64_t)getPrefixCountWithInput:(char*)ins LetterCounts:(int*)letterCounter;
+(int64_t)getWordCountWithInput:(char*)ins LetterCounts:(int*)letterCounter;

@end
