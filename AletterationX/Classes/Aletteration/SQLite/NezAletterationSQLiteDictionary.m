//
//  NezSQLiteDictionary.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <sqlite3.h>
#import "NezAletterationSQLiteDictionary.h"
#import "NezSQLite.h"
#import "NezAletterationGameState.h"

#define DB_DIC_FILE_NAME @"words"

NezAletterationSQLiteDictionary *g_NezSQLiteDictionary;

@implementation NezAletterationSQLiteDictionary {
	sqlite3 *_database;
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
		 g_NezSQLiteDictionary = [[NezAletterationSQLiteDictionary alloc] init];
    }
}

-(id)init {
	if ((self = [super init])) {
		NSString *resourcePath = [[NSBundle mainBundle] pathForResource:DB_DIC_FILE_NAME ofType:DB_FILE_TYPE inDirectory:DB_FOLDER];
		if (sqlite3_open([resourcePath UTF8String], &_database) == SQLITE_OK) {
		} else {
			_database = NULL;
			self = nil;
		}
	}
	return self;
}

-(void)dealloc {
	if (_database) {
		sqlite3_close(_database);
	}
}

+(NezAletterationDictionaryCounts)getCountsWithInput:(char*)ins LetterCounts:(int*)letterCounts {
	return [g_NezSQLiteDictionary getCountsWithInput:ins LetterCounts:letterCounts];
}

+(int64_t)getPrefixCountWithInput:(char*)ins LetterCounts:(int*)letterCounts {
	return [g_NezSQLiteDictionary getPrefixCountWithInput:ins LetterCounts:letterCounts];
}

+(int64_t)getWordCountWithInput:(char*)ins LetterCounts:(int*)letterCounts {
	return [g_NezSQLiteDictionary getWordCountWithInput:ins LetterCounts:letterCounts];
}

-(NezAletterationDictionaryCounts)getCountsWithInput:(char*)ins LetterCounts:(int*)letterCounts {
	NezAletterationDictionaryCounts counts;
	counts.prefixCount = [self getPrefixCountWithInput:ins LetterCounts:letterCounts];
	counts.wordCount = [self getWordCountWithInput:ins LetterCounts:letterCounts];
	return counts;
}

-(int64_t)getPrefixCountWithInput:(char*)ins LetterCounts:(int*)letters {
	long prefixCount = 0;
	for (int i=0; ins[i]; i++) {
		letters[ins[i]-'a']++;
	}
	NSString *selectPrefixCountSQL = [NSString stringWithFormat:@"SELECT COUNT(word) FROM t_%c WHERE word LIKE '%s%%' AND count >= 4 AND a <= %d AND b <= %d AND c <= %d AND d <= %d AND e <= %d AND f <= %d AND g <= %d AND h <= %d AND i <= %d AND j <= %d AND k <= %d AND l <= %d AND m <= %d AND n <= %d AND o <= %d AND p <= %d AND q <= %d AND r <= %d AND s <= %d AND t <= %d AND u <= %d AND v <= %d AND w <= %d AND x <= %d AND y <= %d AND z <= %d", ins[0], ins, letters[0], letters[1], letters[2], letters[3], letters[4], letters[5], letters[6], letters[7], letters[8], letters[9], letters[10], letters[11], letters[12], letters[13], letters[14], letters[15], letters[16], letters[17], letters[18], letters[19], letters[20], letters[21], letters[22], letters[23], letters[24], letters[25]];
	if (sqlite3_exec(_database, [selectPrefixCountSQL UTF8String], CountSelectCallback, &prefixCount, NULL) == SQLITE_OK) {
		return prefixCount;
	}
	return -1;
}

-(int64_t)getWordCountWithInput:(char*)ins LetterCounts:(int*)letters {
	long wordCount = 0;
	for (int i=0; ins[i]; i++) {
		letters[ins[i]-'a']++;
	}
	NSString *selectWordCountSQL = [NSString stringWithFormat:@"SELECT COUNT(word) FROM t_%c WHERE word = '%s' AND count >= 4 AND a <= %d AND b <= %d AND c <= %d AND d <= %d AND e <= %d AND f <= %d AND g <= %d AND h <= %d AND i <= %d AND j <= %d AND k <= %d AND l <= %d AND m <= %d AND n <= %d AND o <= %d AND p <= %d AND q <= %d AND r <= %d AND s <= %d AND t <= %d AND u <= %d AND v <= %d AND w <= %d AND x <= %d AND y <= %d AND z <= %d", ins[0], ins, letters[0], letters[1], letters[2], letters[3], letters[4], letters[5], letters[6], letters[7], letters[8], letters[9], letters[10], letters[11], letters[12], letters[13], letters[14], letters[15], letters[16], letters[17], letters[18], letters[19], letters[20], letters[21], letters[22], letters[23], letters[24], letters[25]];
	if (sqlite3_exec(_database, [selectWordCountSQL UTF8String], CountSelectCallback, &wordCount, NULL) == SQLITE_OK) {
		return wordCount;
	}
	return -1;
}

@end
