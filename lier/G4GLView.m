//
//  G4GLView.m
//  lier
//
//  Created by xu james on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//

#import "G4GLView.h"
#import "math/CC3GLMatrix.h"

@implementation G4GLView

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2]; // New
} Vertex;

/*const Vertex Vertices[] = {
 {{1, -1, 0}, {1, 0, 0, 1}},
 {{1, 1, 0}, {0, 1, 0, 1}},
 {{-1, 1, 0}, {0, 0, 1, 1}},
 {{-1, -1, 0}, {0, 0, 0, 1}}
 };
 
 const GLubyte Indices[] = {
 0, 1, 2,
 2, 3, 0
 };*/

#define TEX_COORD_MAX   1

const Vertex Vertices[] = {
    // Front
    {{1, -1, 1}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, 1}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, 1}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, 1}, {1, 1, 1, 1}, {0, 0}},
    // Back
    {{1, 1, -1}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-1, 1, -1}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, -1}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, -1}, {1, 1, 1, 1}, {0, 0}},
    // Left
    {{-1, -1, 1}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}}, 
    {{-1, 1, 1}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -1}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -1}, {1, 1, 1, 1}, {0, 0}},
    // Right
    {{1, -1, -1}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -1}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 1}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, 1}, {1, 1, 1, 1}, {0, 0}},
    // Top
    {{1, 1, 1}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -1}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -1}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, 1}, {1, 1, 1, 1}, {0, 0}},
    // Bottom
    {{1, -1, -1}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{1, -1, 1}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, 1}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}}, 
    {{-1, -1, -1}, {1, 1, 1, 1}, {0, 0}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    6, 7, 4,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

const Vertex Vertices2[] = {
    {{1, -1, 0.01}, {1, 1, 1, 1}, {1, 1}},
    {{1, 1, 0.01}, {1, 1, 1, 1}, {1, 0}},
    {{-1, 1, 0.01}, {1, 1, 1, 1}, {0, 0}},
    {{-1, -1, 0.01}, {1, 1, 1, 1}, {0, 1}},
};

const GLubyte Indices2[] = {
    1, 0, 2, 3
};

const CC3Vector LiceFace[6] = { 
    {0,-20,20},{-20,90,-20},{90,0,0},
    {-90,0,0},{0,-90,0},{180,0,0}
};

const CC3Vector LiceFace2[6] = { 
    {0,0,0},{0,90,0},{90,0,0},
    {-90,0,0},{0,-90,0},{180,0,0}
};

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = NO;
}

- (void)setupContext {   
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);        
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);    
}

- (void)setupFrameBuffer {    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);   
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    _texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    _lightUniform = glGetUniformLocation(programHandle, "light");
    _materialUniform = glGetUniformLocation(programHandle, "material");
    _textureUniform = glGetUniformLocation(programHandle, "Texture");

    
}

- (void)setupVBOs {
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_vertexBuffer2);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices2), Vertices2, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer2);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer2);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices2), Indices2, GL_STATIC_DRAW);
    
}

- (void)render:(CADisplayLink*)displayLink {
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
     
   // glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);        
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 16.0f * self.frame.size.height / self.frame.size.width;
    [projection populateOrthoFromFrustumLeft:-8 andRight:8 andBottom:-h/2 andTop:h/2 andNear:4 andFar:50];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    glViewport(0,0, self.frame.size.width, self.frame.size.height);
   
    const float PI = PI;
    int y[][4] = { { 4,8,-20, PI/3},{5,-8,-20,PI/5},{7,4,-20,PI/6},{-4,-4,-20,PI/2},{0,0,-20,PI*2/3}, {-4,5,0,PI*2/5}};
    
    for( int i = 0; i < MAX_LICE_NUMBER ; i++ ) {
        
        CC3GLMatrix *modelView = [CC3GLMatrix matrix];
        [modelView populateFromTranslation:CC3VectorMake(  ((int)(y[i][0]+  7 *sin(y[i][3]+CACurrentMediaTime()))) %7 , y[i][1],-12)];
        
        [modelView rotateBy:LiceFace[i]];
        
//          _currentRotation[i] += displayLink.duration *300*RandomFloat();      
        
//        [modelView rotateBy:CC3VectorMake(_currentRotation[i], _currentRotation[i], 0)];

        glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);     
        // 2
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
        glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
        
        glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));    
        
        glActiveTexture(GL_TEXTURE0); 

        glUniform1i(_textureUniform, 0); 

        for( int j =0 ; j < 6 ;j++ ) {
            
            glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices)/6, Vertices+j*sizeof(Vertices)/6, GL_STATIC_DRAW);
           
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices)/6, Indices+j*sizeof(Indices)/6, GL_STATIC_DRAW);            

            glBindTexture(GL_TEXTURE_2D, _cubeSideTexture[j]);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);        
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, 0);        
        }
    }    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)render2:(CADisplayLink*)displayLink {
    
    int a = (int)CACurrentMediaTime() % 4;
    static bool bPause = false;
    if( a >=2 && a<=3  ) {
        bPause = true;
     } 
    else 
        bPause = false;

    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    
    // glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);        
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 16.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-8 andRight:8 andBottom:0 andTop:h andNear:40 andFar:150];
 
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    glViewport(0,0, self.frame.size.width, self.frame.size.height);
    const char X =0, Y=1 ,Z=2;
    
    static double licePos[MAX_LICE_NUMBER][3] = { { -4,8,-20},{4,12,-20},{3,4,-20},{6,15,-20},{-4,17,-20},{-6,26,-20}}; 
    
   static float moveDirection[MAX_LICE_NUMBER] = { 3.14/6, 3.14/5,3.14/10,3.14/2,3.14/7,3.14/9  };
    static float speed[MAX_LICE_NUMBER] = {0.1,0.2,0.3,0.4,0.5,0.6  };
    for( int i = 0; i < MAX_LICE_NUMBER ; i++ ) {
        
        CC3GLMatrix *modelView = [CC3GLMatrix matrix];
        
        if( bPause) { 
           
        }
        else {
            licePos[i][X]+= speed[i]*cosf(moveDirection[i]);
            licePos[i][Y] += speed[i]*sinf(moveDirection[i]);
            
            if(licePos[i][X] > 8 ) 
                moveDirection[i] = 3.14 -  moveDirection[i];
            else if( licePos[i][X] < -8)
                moveDirection[i] = 3.14 +  moveDirection[i];;


            if(licePos[i][Y] > 24 ) 
                moveDirection[i] = 3.14/2+  moveDirection[i];
            else if( licePos[i][Y] <0) {
                moveDirection[i] = -  moveDirection[i];;
                licePos[i][Y] = 1;
            }
            if( i == 5) 
                NSLog(@"%f",moveDirection[i]);

        }
        [modelView populateFromTranslation:CC3VectorMake(licePos[i][0], licePos[i][1],-50)];   
        static bool firstPause = true;
        static unsigned int randomAngle[3] ;
        if( bPause) { 

            [modelView rotateBy:LiceFace2[i]];
            if( firstPause ) 
            {   
                randomAngle[0] = RandomUInt();
                randomAngle[1] = RandomUInt();
                randomAngle[2] = RandomUInt();
                
            }
            if( i== 0 || i ==5 )
                [modelView rotateByZ:randomAngle[0] ];
            else if( i==2 || i == 3)
                [modelView rotateByY:randomAngle[1] ];
            else
                [modelView rotateByX:randomAngle[2] ];
            
            firstPause = false;
            
        }
        else {
            firstPause = true;
            
            _currentRotation[i] += displayLink.duration *390*RandomFloatBetween(0.5,1.5);
            [modelView rotateBy:CC3VectorMake(_currentRotation[i] , _currentRotation[i]/2,_currentRotation[i]/3)];        
        }
        glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
       
        // 2
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
        glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
        
        glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));    
        
        glActiveTexture(GL_TEXTURE0);         
        glUniform1i(_textureUniform, 0); 
        
        for( int j =0 ; j < 6 ;j++ ) {
            
            glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices)/6, Vertices+j*sizeof(Vertices)/6, GL_STATIC_DRAW);
            
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices)/6, Indices+j*sizeof(Indices)/6, GL_STATIC_DRAW);            
            
            glBindTexture(GL_TEXTURE_2D, _cubeSideTexture[j]);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);        
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, 0);        
        }
    }
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render2:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (GLuint)setupTexture:(NSString *)fileName {
    
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);    
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER , GL_LINEAR); 
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;
    
}
-(void) setupAllTextture
{
    _cubeSideTexture[0] = [self setupTexture:@"1.png"];
    _cubeSideTexture[1] = [self setupTexture:@"6.png"];
    _cubeSideTexture[2] = [self setupTexture:@"2.png"];
    _cubeSideTexture[3] = [self setupTexture:@"5.png"];
    _cubeSideTexture[4] = [self setupTexture:@"3.png"];
    _cubeSideTexture[5] = [self setupTexture:@"4.png"];
    _floorTexture = [self setupTexture:@"1.png"];
}


- (id)initWithFrame:(CGRect)frame
{
    for(int i = 0 ;i < MAX_LICE_NUMBER ; i++ )
        _currentZ[i]= -15;
        
    self = [super initWithFrame:frame];
    if (self) {        
        [self setupLayer];        
        [self setupContext];    
        [self setupDepthBuffer];
        [self setupRenderBuffer];        
        [self setupFrameBuffer];     
        [self compileShaders];
        [self setupVBOs];
        [self setupAllTextture];
        [self setupDisplayLink];

    }
    return self;
}

- (void)dealloc
{
    [_context release];
    _context = nil;
    [super dealloc];
}

@end
