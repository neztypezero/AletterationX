//
//  NezRandom.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#ifndef Aletteration3_NezRandom_h
#define Aletteration3_NezRandom_h

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
	
#define NEZ_ARC4RANDOM_MAX 0x100000000
#define NEZ_ARC4RANDOM_MAX_FLOAT_CASTED ((float)NEZ_ARC4RANDOM_MAX)

	static inline float randomFloat() {
		return ((float)arc4random())/NEZ_ARC4RANDOM_MAX_FLOAT_CASTED;
	}
	
	static inline float randomFloatBetween(float start, float end) {
		float length = end-start;
		return randomFloat() * length + start;
	}
	
	static inline float randomFloatInRange(float start, float length) {
		return randomFloat() * length + start;
	}
	
	static inline int randomIntInRange(int start, int length) {
		return (int)(randomFloat() * length + start);
	}
	
	static inline float randomVariation(float iValue, float iVariation) {
		float variation = randomFloatInRange(-1.0, 2.0) * iVariation;
		return iValue + variation;
	}

#endif

#ifdef __cplusplus
}
#endif