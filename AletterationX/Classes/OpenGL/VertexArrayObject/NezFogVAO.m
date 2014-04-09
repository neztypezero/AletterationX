//
//  NezFogVAO.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezFogVAO.h"
#import "NezVertex2VBO.h"
#import "NezGLSLProgramFog.h"

@implementation NezFogVAO

-(NezVertex2VBO*)vertexBufferObject {
	return _vertexBufferObject;
}

-(void)draw {
	NezGLSLProgramFog *p = self.program;
	glBindVertexArray(self.vertexArrayObject);
	glUseProgram(p.program);

	bindTexture2D(_colorTexture, GL_TEXTURE0, p.u_colorTexture);
	bindTexture2D(_depthTexture, GL_TEXTURE1, p.u_depthTexture);
	glUniform4fv(p.u_fogColor, 1, _fogColor.v);
	glUniform2fv(p.u_uvRatio, 1, _uvRatio.v);

	glDrawElements(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0);

	unbindTexture2D(GL_TEXTURE0);
	unbindTexture2D(GL_TEXTURE1);
	glUseProgram(0);
	glBindVertexArray(0);
}

@end
