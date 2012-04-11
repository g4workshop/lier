//
//  G4GLView.h
//  lier
//
//  Created by xu james on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#define MAX_LICE_NUMBER  6

@interface G4GLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    GLuint _materialUniform;
    GLuint _lightUniform;
    
    float _currentRotation[MAX_LICE_NUMBER];
    float _currentZ[MAX_LICE_NUMBER];
    GLuint _depthRenderBuffer;
    
    GLuint _floorTexture;
    GLuint _cubeSideTexture[6];
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _vertexBuffer2;
    GLuint _indexBuffer2;
}

@end
