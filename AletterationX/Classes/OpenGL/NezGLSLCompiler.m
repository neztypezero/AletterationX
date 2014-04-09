//
//  NezGLSLCompiler.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import "NezGLSLCompiler.h"

#define SHADER_FOLDER @"Shaders"

@implementation NezGLSLCompiler

+(instancetype)compilerWithVertexShader:(NSString*)vsh {
	return [[NezGLSLCompiler alloc] initWithVertexShader:vsh];
}

+(instancetype)compilerWithFragmentShader:(NSString*)fsh {
	return [[NezGLSLCompiler alloc] initWithFragmentShader:fsh];
}

+(instancetype)compilerWithGeometryShader:(NSString*)gsh {
	return [[NezGLSLCompiler alloc] initWithGeometryShader:gsh];
}

-(instancetype)initWithVertexShader:(NSString*)vsh {
	return [self initWithShader:vsh andType:GL_VERTEX_SHADER];
}

-(instancetype)initWithFragmentShader:(NSString*)fsh {
	return [self initWithShader:fsh andType:GL_FRAGMENT_SHADER];
}

-(instancetype)initWithGeometryShader:(NSString*)gsh {
	return [self initWithShader:gsh andType:GL_GEOMETRY_SHADER];
}

-(instancetype)initWithShader:(NSString*)shader andType:(GLenum)shaderType {
	if ((self = [super init])) {
		NSString *fileType;
		if (shaderType==GL_VERTEX_SHADER) {
			fileType = @"vsh";
		} else if (shaderType==GL_FRAGMENT_SHADER) {
			fileType = @"fsh";
		} else if (shaderType==GL_GEOMETRY_SHADER) {
			fileType = @"gsh";
		} else {
			return nil;
		}
		
		// Create and compile fragment shader
		NSString *file = [[NSBundle mainBundle] pathForResource:shader ofType:fileType inDirectory:SHADER_FOLDER];
		if (!file) {
			return nil;
		}
		if (![self compileShaderForType:shaderType andFile:file]) {
			NSLog(@"Failed to compile %@ shader", shaderType==GL_VERTEX_SHADER?@"GL_VERTEX_SHADER":(shaderType==GL_FRAGMENT_SHADER?@"GL_FRAGMENT_SHADER":@"GL_GEOMETRY_SHADER"));
			return nil;
		}
	}
	return self;
}

-(BOOL)compileShaderForType:(GLenum)shaderType andFile:(NSString *)file {
	GLint status;
	
	const GLchar *source;
	__block NSString *programString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
	
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\#include\\s+\"(\\w+\\/)*(\\w+)\\.(\\w+)\"" options:NSRegularExpressionCaseInsensitive error:&error];
	NSArray *matches = [regex matchesInString:programString options:0 range:NSMakeRange(0, [programString length])];
	[matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		NSRange matchRange = [match range];
		NSRange includePathRange = [match rangeAtIndex:1];
		NSRange filenameRange = [match rangeAtIndex:2];
		NSRange fileTypeRange = [match rangeAtIndex:3];

		NSString *includePath;
		if (includePathRange.location == NSNotFound || includePathRange.length == 0) {
			includePath = @"";
		} else {
			includePath = [programString substringWithRange:includePathRange];
		}
		NSString *filename = [programString substringWithRange:filenameRange];
		NSString *fileType = [programString substringWithRange:fileTypeRange];
		NSString *fullPath = [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:[NSString stringWithFormat:@"%@/%@", SHADER_FOLDER, includePath]];

		NSStringEncoding enc;
		NSError *error;
		NSString *includeFile = [NSString stringWithContentsOfFile:fullPath usedEncoding:&enc error:&error];
		if (includeFile) {
			programString = [programString stringByReplacingCharactersInRange:matchRange withString:includeFile];
		} else {
			programString = [programString stringByReplacingCharactersInRange:matchRange withString:@""];
		}
	}];

	source = (GLchar*)[programString UTF8String];
	if (!source) {
		NSLog(@"Failed to load %@ shader", shaderType==GL_VERTEX_SHADER?@"GL_VERTEX_SHADER":(shaderType==GL_FRAGMENT_SHADER?@"GL_FRAGMENT_SHADER":@"GL_GEOMETRY_SHADER"));
		return FALSE;
	}
	
	_shader = glCreateShader(shaderType);
	glShaderSource(_shader, 1, &source, NULL);
	glCompileShader(_shader);
	
#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(_shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(_shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif
	
	glGetShaderiv(_shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
		glDeleteShader(_shader);
		_shader = 0;
		return NO;
	}
	return YES;
}

-(void)dealloc {
	if (_shader) {
		glDeleteShader(_shader);
		_shader = 0;
	}
}

@end

