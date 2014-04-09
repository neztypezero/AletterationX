//
//  NezGLSLCompiler.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import <OpenGL/gl3.h>

@interface NezGLSLCompiler : NSObject {
}

@property (readonly) GLuint shader;

+(instancetype)compilerWithVertexShader:(NSString*)vsh;
+(instancetype)compilerWithFragmentShader:(NSString*)fsh;
+(instancetype)compilerWithGeometryShader:(NSString*)gsh;

-(instancetype)initWithVertexShader:(NSString*)vsh;
-(instancetype)initWithFragmentShader:(NSString*)fsh;
-(instancetype)initWithGeometryShader:(NSString*)gsh;

@end
