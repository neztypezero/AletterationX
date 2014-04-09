//
//  NezVertexTypes.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#ifndef Aletteration3_NezVertexTypes_h
#define Aletteration3_NezVertexTypes_h

typedef struct {
	GLKVector2 position;
} NezVertex2;

typedef struct {
	GLKVector3 position;
} NezVertex3;

typedef struct {
	GLKVector4 position;
	GLKVector2 uv;
} NezVertexP4T2;

typedef struct {
	GLKVector3 position;
	GLKVector3 normal;
} NezLitVertex;

typedef struct {
	GLKVector3 position;
	GLKVector2 uv;
} NezTextureVertex;

typedef struct {
	GLKVector3 position;
	float uvIndex;
} NezInstanceTextureVertex;

typedef struct {
	GLKVector3 position;
	GLKVector3 normal;
	float uvIndex;
} NezLitInstanceTextureVertex;

typedef struct {
	GLKVector3 position;
	GLKVector3 normal;
	GLKVector2 uv;
} NezLitTextureVertex;

typedef struct {
	GLKVector4 position; // xyz: particle position, w: size
	GLKVector3 velocity; // xyz: particle velocity
	GLKVector2 uv; 		// x:angle, y: life [0..1]
} NezVertexParticle;

#endif
