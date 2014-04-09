//
//  NezGLSLProgramProtocols.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/30.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

@protocol NezAttribute_position
@required
@property (readonly) GLint a_position;
@end
@protocol NezAttribute_pos
@required
@property (readonly) GLint a_pos;
@end
@protocol NezAttribute_vel
@required
@property (readonly) GLint a_vel;
@end
@protocol NezAttribute_uv
@required
@property (readonly) GLint a_uv;
@end
