//
//  NezSimpleObjLoader.m
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezSimpleObjLoader.h"

static const float NEZ_FLOATING_POINT_EPSILON = 1e-6f;

static inline BOOL isCloseEnough(double a, double b) {
	return fabsf((a - b) / ((b == 0.0f) ? 1.0f : b)) < NEZ_FLOATING_POINT_EPSILON;
}

typedef union {
	struct {
		GLKVector3 min;
		GLKVector3 max;
	};
	GLKVector3 bounds[2];
} NezBoundingBox;

@interface NezSimpleObjGroup : NSObject {
}

@property (nonatomic, assign) NSInteger firstIndex;
@property (nonatomic, assign) NSInteger indexCount;
@property (nonatomic, assign) NSInteger firstVertex;
@property (nonatomic, assign) NSInteger vertexCount;

@end

@implementation NezSimpleObjGroup

-(instancetype)initWithFirstVertex:(NSInteger)vertex Index:(NSInteger)index {
	if ((self = [super init])) {
		_firstVertex = vertex;
		_vertexCount = 0;
		_firstIndex = index;
		_indexCount = 0;
	}
	return self;
}

@end

@interface IndexedVertexObj : NSObject {
}

@property (nonatomic, assign) NSInteger vertexIndex;
@property (nonatomic, assign) NSInteger normalIndex;
@property (nonatomic, assign) NSInteger uvIndex;
@property (nonatomic, assign) NSInteger vertexArrayIndex;

+(IndexedVertexObj*)indexedVertexObj;

@end

@implementation IndexedVertexObj

+(IndexedVertexObj*)indexedVertexObj {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		_vertexIndex = -1;
		_normalIndex = -1;
		_uvIndex = -1;
		_vertexArrayIndex = -1;
	}
	return self;
}

@end

@implementation NezSimpleObjLoader

-(void)scaleVerticesWithUniformScaleFactor:(float)scaleFactor {
	[self scaleVertices:GLKMatrix3MakeScale(scaleFactor, scaleFactor, scaleFactor)];
}

-(void)scaleVertices:(GLKMatrix3)scaleMatrix {
	for (NSInteger i=0; i<self.vertexArray.vertexCount; i++) {
		NezModelVertex *v = &self.vertexArray.vertexList[i];
		v->position = GLKMatrix3MultiplyVector3(scaleMatrix, v->position);
	}
	_size = GLKMatrix3MultiplyVector3(scaleMatrix, _size);
}

-(void)translateVertices:(GLKVector3)translationVector {
	for (NSInteger i=0; i<self.vertexArray.vertexCount; i++) {
		NezModelVertex *v = &self.vertexArray.vertexList[i];
		v->position = GLKVector3Add(v->position, translationVector);
	}
}

-(NezBoundingBox)calculateAABB {
	NezBoundingBox aabb;
	
	if (self.vertexArray.vertexCount > 0) {
		GLKVector3 min = self.vertexArray.vertexList[0].position;
		GLKVector3 max = self.vertexArray.vertexList[0].position;
		for (NSInteger i=1; i<self.vertexArray.vertexCount; i++) {
			NezModelVertex *v = &self.vertexArray.vertexList[i];
			if (min.x > v->position.x) { min.x = v->position.x; }
			if (min.y > v->position.y) { min.y = v->position.y; }
			if (min.z > v->position.z) { min.z = v->position.z; }
			if (max.x < v->position.x) { max.x = v->position.x; }
			if (max.y < v->position.y) { max.y = v->position.y; }
			if (max.z < v->position.z) { max.z = v->position.z; }
		}
		aabb.min = min;
		aabb.max = max;
	} else {
		aabb.min = GLKVector3Make(0.0f, 0.0f, 0.0f);
		aabb.max = GLKVector3Make(0.0f, 0.0f, 0.0f);
	}
	_size.x = aabb.max.x-aabb.min.x;
	_size.y = aabb.max.y-aabb.min.y;
	_size.z = aabb.max.z-aabb.min.z;

	return aabb;
}

-(instancetype)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	if ((self = [super init])) {
		_groupDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
		_vertexArray = [NezSimpleObjLoader loadVertexArrayWithFile:file Type:ext Dir:dir Groups:_groupDictionary];
		if (self.vertexArray.vertexCount > 0) {
			NezBoundingBox aabb = [self calculateAABB];
			GLKVector3 center = GLKVector3Lerp(aabb.max, aabb.min, 0.5);
			if (!isCloseEnough(center.x, 0.0f) || !isCloseEnough(center.y, 0.0f) || !isCloseEnough(center.z, 0.0f)) {
				[self translateVertices:GLKVector3MultiplyScalar(center, -1.0)];
			}
		} else {
			_size = GLKVector3Make(0, 0, 0);
		}
	}
	return self;
}

-(instancetype)initWithObjLoader:(NezSimpleObjLoader*)objLoader andGroupNameList:(NSArray*)groupNameList {
	if ((self = [super init])) {
		_groupDictionary = nil;
		_vertexArray = [objLoader makeVertexArrayForGroupNameList:groupNameList];
		if (self.vertexArray.vertexCount > 0) {
			NezBoundingBox aabb = [self calculateAABB];
			GLKVector3 center = GLKVector3Lerp(aabb.max, aabb.min, 0.5);
			if (!isCloseEnough(center.x, 0.0f) || !isCloseEnough(center.y, 0.0f) || !isCloseEnough(center.z, 0.0f)) {
				[self translateVertices:GLKVector3Negate(center)];
			}
		} else {
			_size = GLKVector3Make(0, 0, 0);
		}
	}
	return self;
}

+(NSString*)getModelResourcePathWithFilename:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir {
	return [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
}

-(NezModelVertexArray*)makeVertexArrayForGroupName:(NSString*)groupName {
	return [self makeVertexArrayForGroupNameList:@[groupName]];
}

-(NezModelVertexArray*)makeVertexArrayForGroupNameList:(NSArray*)groupNameList {
	if (_groupDictionary) {
		int totalVertexCount = 0;
		int totalIndexCount = 0;
		
		for (NSString *groupName in groupNameList) {
			NezSimpleObjGroup *group = [_groupDictionary objectForKey:groupName];
			totalVertexCount += group.vertexCount;
			totalIndexCount += group.indexCount;
		}
		if (totalVertexCount > 0 && totalIndexCount > 0) {
			NezModelVertexArray *array = [[NezModelVertexArray alloc] initWithVertexCount:totalVertexCount andIndexCount:totalIndexCount];
			unsigned short *indexList = array.indexList;
			NezModelVertex *vertexList = array.vertexList;
			NSInteger firstVertex = 0;
			for (NSString *groupName in groupNameList) {
				NezSimpleObjGroup *group = [_groupDictionary objectForKey:groupName];

				for (NSInteger i=0; i<group.indexCount; i++) {
					indexList[i] = firstVertex+self.vertexArray.indexList[group.firstIndex+i]-group.firstVertex;
				}
				memcpy(vertexList, &self.vertexArray.vertexList[group.firstVertex], sizeof(NezModelVertex)*group.vertexCount);
				indexList = &indexList[group.indexCount];
				firstVertex += group.vertexCount;
				vertexList = &vertexList[group.vertexCount];
			}
			return array;
		}
	}
	return nil;
}

-(NezSimpleObjLoader*)makeObjLoaderForGroup:(NSString*)groupName {
	return [self makeObjLoaderForGroupNameList:@[groupName]];
}

-(NezSimpleObjLoader*)makeObjLoaderForGroupNameList:(NSArray*)groupNameList {
	return [[NezSimpleObjLoader alloc] initWithObjLoader:self andGroupNameList:groupNameList];
}

+(NezModelVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	return [NezSimpleObjLoader loadVertexArrayWithFile:file Type:ext Dir:dir Groups:nil];
}

+(NezModelVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic {
	NSMutableArray *vertexList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *normalList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *uvList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *indexList = [NSMutableArray arrayWithCapacity:128];
	NSMutableDictionary *indexDic = [NSMutableDictionary dictionaryWithCapacity:128];
	
	NSString *path = [NezSimpleObjLoader getModelResourcePathWithFilename:file Type:ext Dir:dir];
	
	FILE *objFile = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "rb");
	char line[1024];
	
	NezSimpleObjGroup *curentGroup = nil;
	
	while (fgets(line, 1023, objFile)) {
		switch (line[0]) {
			case 'v':
				switch (line[1]) {
					case ' ':
						[NezSimpleObjLoader readVertexFrom:line into:vertexList];
						break;
					case 't':
						[NezSimpleObjLoader readUVFrom:line into:uvList];
						break;
					case 'n':
						[NezSimpleObjLoader readNormalFrom:line into:normalList];
						break;
					default:
						break;
				}
				break;
			case 'f':
				[NezSimpleObjLoader readFaceFrom:line into:indexList with:indexDic];
				break;
			case 'g':
				if (groupDic != nil && line[1] ==  ' ') {
					if (curentGroup) {
						curentGroup.vertexCount = [indexDic count]-curentGroup.firstVertex;
						curentGroup.indexCount = [indexList count]-curentGroup.firstIndex;
					}
					curentGroup = [NezSimpleObjLoader readGroupFrom:line into:groupDic withFirstVertex:[indexDic count] Index:[indexList count]];
				} else if (curentGroup) {
					curentGroup.vertexCount = [indexDic count]-curentGroup.firstVertex;
					curentGroup.indexCount = [indexList count]-curentGroup.firstIndex;
					curentGroup = nil;
				}
				break;
			default:
				break;
		}
	}
	fclose(objFile);
	
	if (curentGroup) {
		curentGroup.vertexCount = indexDic.count-curentGroup.firstVertex;
		curentGroup.indexCount = indexList.count-curentGroup.firstIndex;
		curentGroup = nil;
	}
	if ([indexList count] > 0) {
		NezModelVertexArray *varray = [[NezModelVertexArray alloc] initWithVertexCount:(int)[indexDic count] andIndexCount:(int)[indexList count]];
		for (IndexedVertexObj *indexedVertex in [indexDic objectEnumerator]) {
			NezModelVertex *v = &varray.vertexList[indexedVertex.vertexArrayIndex];
			[((NSValue*)[vertexList objectAtIndex:indexedVertex.vertexIndex]) getValue:&v->position];
			[((NSValue*)[uvList objectAtIndex:indexedVertex.uvIndex]) getValue:&v->uv];
			[((NSValue*)[normalList objectAtIndex:indexedVertex.normalIndex]) getValue:&v->normal];
		}
		NSInteger i=0;
		unsigned short *vaIndexList = varray.indexList;
		for (IndexedVertexObj *indexedVertex in indexList) {
			vaIndexList[i++] = indexedVertex.vertexArrayIndex;
		}
		return varray;
	} else {
		return nil;
	}
}

+(float)getFloatFromCString:(char*)string Next:(char**)next {
	char *start = string;
	for(;;start++) {
		if (*start == '-') {
			break;
		}
		if (*start >= '0' && *start <= '9') {
			break;
		}
	}
	char *end = start;
	for(;;end++) {
		if ((*end >= '0' && *end <= '9') || *end == '-' || *end == '.') {
			continue;
		}
		break;
	}
	*end = '\0';
	*next = end+1;
	return atof(start);
}

+(void)readVertexFrom:(char*)line into:(NSMutableArray*)vertexList {
	GLKVector3 pos = {
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line]
	};
	[vertexList addObject:[NSValue valueWithBytes:&pos objCType:@encode(GLKVector3)]];
}

+(void)readNormalFrom:(char*)line into:(NSMutableArray*)normalList {
	GLKVector3 normal = {
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line]
	};
	[normalList addObject:[NSValue valueWithBytes:&normal objCType:@encode(GLKVector3)]];
}

+(void)readUVFrom:(char*)line into:(NSMutableArray*)uvList {
	GLKVector2 uv = {
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
		[NezSimpleObjLoader getFloatFromCString:line Next:&line],
	};
	[uvList addObject:[NSValue valueWithBytes:&uv objCType:@encode(GLKVector2)]];
}

+(void)readFaceFrom:(char*)line into:(NSMutableArray*)indexList with:(NSMutableDictionary*)indexDic {
	NSString *string = [NSString stringWithFormat:@"%s", line];
	NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSCharacterSet *slashCharSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
	for (NSString *s in lines) {
		NSRange range = [s rangeOfCharacterFromSet:slashCharSet];
		if (range.location != NSNotFound) {
			IndexedVertexObj *indexedVertex = [IndexedVertexObj indexedVertexObj];
			IndexedVertexObj *value = [indexDic objectForKey:s];
			if (value) {
				indexedVertex.vertexArrayIndex = value.vertexArrayIndex;
			} else {
				NSArray *iList = [s componentsSeparatedByCharactersInSet:slashCharSet];
				indexedVertex.vertexIndex = [[iList objectAtIndex:0] integerValue]-1;
				indexedVertex.uvIndex = [[iList objectAtIndex:1] integerValue]-1;
				indexedVertex.normalIndex = [[iList objectAtIndex:2] integerValue]-1;
				indexedVertex.vertexArrayIndex = [indexDic count];
				[indexDic setObject:indexedVertex forKey:s];
			}
			[indexList addObject:indexedVertex];
		}
	}
}

+(NezSimpleObjGroup*)readGroupFrom:(char*)line into:(NSMutableDictionary*)groupDictionary withFirstVertex:(NSInteger)firstVertex Index:(NSInteger)firstIndex {
	NSString *string = [NSString stringWithFormat:@"%s", line];
	NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([words count] > 1) {
		NezSimpleObjGroup *group = [[NezSimpleObjGroup alloc] initWithFirstVertex:firstVertex Index:firstIndex];
		[groupDictionary setObject:group forKey:[words objectAtIndex:1]];
		return group;
	}
	return nil;
}

@end
