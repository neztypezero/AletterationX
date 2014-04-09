//
//  NezSimpleObjLoader.h
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezModelVertexArray.h"

@interface NezSimpleObjLoader : NSObject {
	NSMutableDictionary *_groupDictionary;
}

@property (readonly) NezModelVertexArray *vertexArray;
@property (readonly) GLKVector3 size;

-(instancetype)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir;
+(NezModelVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir;
+(NezModelVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic;

-(NezModelVertexArray*)makeVertexArrayForGroupName:(NSString*)groupName;
-(NezModelVertexArray*)makeVertexArrayForGroupNameList:(NSArray*)groupNameList;

-(NezSimpleObjLoader*)makeObjLoaderForGroup:(NSString*)groupName;
-(NezSimpleObjLoader*)makeObjLoaderForGroupNameList:(NSArray*)groupNameList;

-(void)scaleVerticesWithUniformScaleFactor:(float)scaleFactor;
-(void)scaleVertices:(GLKMatrix3)scaleMatrix;
-(void)translateVertices:(GLKVector3)translationVector;

@end
