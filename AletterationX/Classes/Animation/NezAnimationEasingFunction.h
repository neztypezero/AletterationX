/*
 *
 * TERMS OF USE - EASING EQUATIONS
 *
 * Open source under the BSD License.
 *
 * Copyright © 2001 Robert Penner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list
 * of conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 *
 * Neither the name of the author nor the names of contributors may be used to endorse
 * or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


#ifndef NEZANIMATION_JQUERY_EASING_FUNCTIONS_H
#define NEZANIMATION_JQUERY_EASING_FUNCTIONS_H

#ifdef __cplusplus
extern "C" {
#endif
	
	#define EASE_LINEAR easeLinear
	#define EASE_IN_QUAD easeInQuad
	#define EASE_OUT_QUAD easeInQuad
	#define EASE_IN_OUT_QUAD easeInOutQuad
	#define EASE_IN_CUBIC easeInCubic
	#define EASE_OUT_CUBIC easeOutCubic
	#define EASE_IN_OUT_CUBIC easeInOutCubic
	#define EASE_IN_QUART easeInQuart
	#define EASE_OUT_QUART easeOutQuart
	#define EASE_IN_OUT_QUART easeInOutQuart
	#define EASE_IN_QUINT easeInQuint
	#define EASE_OUT_QUINT easeOutQuint
	#define EASE_IN_OUT_QUINT easeInOutQuint
	#define EASE_IN_SINE easeInSine
	#define EASE_OUT_SINE easeOutSine
	#define EASE_IN_OUT_SINE easeInOutSine
	#define EASE_IN_EXPO easeInExpo
	#define EASE_OUT_EXPO easeOutExpo
	#define EASE_IN_OUT_EXPO easeInOutExpo
	#define EASE_IN_CIRC easeInCirc
	#define EASE_OUT_CIRC easeOutCirc
	#define EASE_IN_OUT_CIRC easeInOutCirc
	#define EASE_IN_ELASTIC easeInElastic
	#define EASE_OUT_ELASTIC easeOutElastic
	#define EASE_IN_OUT_ELASTIC easeInOutElastic
	#define EASE_IN_BACK easeInBack
	#define EASE_OUT_BACK easeOutBack
	#define EASE_IN_OUT_BACK easeInOutBack
	#define EASE_OUT_BOUNCE easeOutBounce
	#define EASE_IN_BOUNCE easeInBounce
	#define EASE_IN_OUT_BOUNCE easeInOutBounce
	
	typedef float(*EasingFunctionPtr)(float, float, float, float);
	
	float easeLinear(float t, float b, float c, float d);
	
	float easeInQuad(float t, float b, float c, float d);
	float easeOutQuad(float t, float b, float c, float d);
	float easeInOutQuad(float t, float b, float c, float d);
	float easeInCubic(float t, float b, float c, float d);
	float easeOutCubic(float t, float b, float c, float d);
	float easeInOutCubic(float t, float b, float c, float d);
	float easeInQuart(float t, float b, float c, float d);
	float easeOutQuart(float t, float b, float c, float d);
	float easeInOutQuart(float t, float b, float c, float d);
	float easeInQuint(float t, float b, float c, float d);
	float easeOutQuint(float t, float b, float c, float d);
	float easeInOutQuint(float t, float b, float c, float d);
	float easeInSine(float t, float b, float c, float d);
	float easeOutSine(float t, float b, float c, float d);
	float easeInOutSine(float t, float b, float c, float d);
	float easeInExpo(float t, float b, float c, float d);
	float easeOutExpo(float t, float b, float c, float d);
	float easeInOutExpo(float t, float b, float c, float d);
	float easeInCirc(float t, float b, float c, float d);
	float easeOutCirc(float t, float b, float c, float d);
	float easeInOutCirc(float t, float b, float c, float d);
	float easeInElastic(float t, float b, float c, float d);
	float easeOutElastic(float t, float b, float c, float d);
	float easeInOutElastic(float t, float b, float c, float d);
	float easeInBack(float t, float b, float c, float d);
	float easeOutBack(float t, float b, float c, float d);
	float easeInOutBack(float t, float b, float c, float d);
	float easeOutBounce(float t, float b, float c, float d);
	float easeInBounce(float t, float b, float c, float d);
	float easeInOutBounce(float t, float b, float c, float d);
#endif
	
#ifdef __cplusplus
}

#endif

