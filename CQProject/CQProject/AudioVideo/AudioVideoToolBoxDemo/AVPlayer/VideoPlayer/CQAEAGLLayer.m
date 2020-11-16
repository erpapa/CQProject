//
//  CQAEAGLLayer.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAEAGLLayer.h"
#import <AVFoundation/AVFoundation.h>
#import <mach/mach_time.h>
#import <UIKit/UIScene.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

enum {
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_ROTATION_ANGLE,
    UNIFORM_COLOR_CONVERSION_MATRIX,
    NNM_UNIFORMS,
};

GLint uniforms[NNM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

//YUV->RGB
//颜色转换常量（yuv到rgb），包括从16-235/16-240（视频范围）进行调整
static const GLfloat kColorConversion601[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, 这是高清电视的标准
static const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

@interface CQAEAGLLayer()
{
    GLint _backingWidth;
    GLint _backingHeight;
    EAGLContext *_context;
    
    //YUV分为2个YUV视频帧 分为亮度和色读2个纹理
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    // 帧缓冲区
    GLuint _frameBufferHandle;
    // 颜色缓存区
    GLuint _colorBufferHandle;
    // 选择颜色通道
    const GLfloat *_preperredConversion;
}
@property GLuint program;
@end

@implementation CQAEAGLLayer
@synthesize pixelBuffer = _pixelBuffer;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        self.contentsScale = scale;
        // 一个布尔值，指定是否包含完全不透明的内容，默认为NO
        self.opaque = true;
        // kEAGLDrawablePropertyRetainedBacking 指定可绘制表面在显示后是否保留其内容的键，默认为NO
        self.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : [NSNumber numberWithBool:YES]};
        
        [self setFrame:frame];
        
        // 设置要绘制框架的上下文
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            return  nil;
        }
        // 将默认转换设置为BT 709 这是HDTV的标准
        _preperredConversion = kColorConversion709;
        
        [self setupGL];
    }
    return self;
}

- (CVPixelBufferRef)pixelBuffer {
    return _pixelBuffer;
}

- (void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
    }
    
    _pixelBuffer = CVPixelBufferRetain(_pixelBuffer);
    // 获取视频的宽和高
    int frameWidth = (int)CVPixelBufferGetWidth(_pixelBuffer);
    int frameHeight = (int)CVPixelBufferGetHeight(_pixelBuffer);
    
    // 显示pixBuffer
    [self displayPixBuffer:_pixelBuffer width:frameWidth height:frameHeight];
}

- (void)displayPixBuffer:(CVPixelBufferRef)pixBuffer width:(int)width height:(int)height {
    // 判断 _context 是否创建成功，不成功那么无法继续
    if (!_context || [EAGLContext setCurrentContext:_context]) {
        return;
    }
    
    CVReturn err;
    // 返回像素缓冲区的平面数
    size_t planeCount = CVPixelBufferGetPlaneCount(pixBuffer);
    // 使用像素缓冲区的颜色附件，确定颜色的显示矩阵
    //参数1: 像素缓存区
    //参数2: kCVImageBufferYCbCrMatrixKey  YCbCr->RGB
    //参数3: 附件模式,NULL
    CFTypeRef colorAttachments = CVBufferGetAttachment(pixBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    
    // 将一个字符串中的字符范围与另外一个字符中的字符范围比较
    if (CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0 == kCFCompareEqualTo)) {
        _preperredConversion = kColorConversion601;
    } else {
        _preperredConversion = kColorConversion709;
    }
    
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    /**
     CVOpenGLESTextureCacheCreate
     功能:   创建 CVOpenGLESTextureCacheRef 创建新的纹理缓存
     参数1:  kCFAllocatorDefault默认内存分配器.
     参数2:  NULL
     参数3:  EAGLContext  图形上下文
     参数4:  NULL
     参数5:  新创建的纹理缓存
     @result kCVReturnSuccess
     */
    err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
    if (err != noErr) {
        NSLog(@"Error at CVOpenGLEsTextureCacheCreate %d", err);
        return;
    }
    // 激活纹理
    glActiveTexture(GL_TEXTURE0);
    
    // 创建亮度y纹理
    /*
     CVOpenGLESTextureCacheCreateTextureFromImage
     功能:根据CVImageBuffer创建CVOpenGlESTexture 纹理对象
     参数1: 内存分配器,kCFAllocatorDefault
     参数2: 纹理缓存.纹理缓存将管理纹理的纹理缓存对象
     参数3: sourceImage.
     参数4: 纹理属性.默认给NULL
     参数5: 目标纹理,GL_TEXTURE_2D
     参数6: 指定纹理中颜色组件的数量(GL_RGBA, GL_LUMINANCE, GL_RGBA8_OES, GL_RG, and GL_RED (NOTE: 在 GLES3 使用 GL_R8 替代 GL_RED).)
     参数7: 帧宽度
     参数8: 帧高度
     参数9: 格式指定像素数据的格式
     参数10: 指定像素数据的数据类型,GL_UNSIGNED_BYTE
     参数11: planeIndex
     参数12: 纹理输出新创建的纹理对象将放置在此处。
     */
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixBuffer, NULL, GL_TEXTURE_2D, GL_RED_EXT, width, height, GL_RED_EXT, GL_UNSIGNED_BYTE, 0, &_lumaTexture);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d",err);
    }
    // 配置亮度纹理属性
    // 绑定纹理
    glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
    
    // 配置纹理放大缩小过滤方式以及纹理围绕S/T环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //UV-plane 纹理
    // 如果颜色通道个数>1 则除了Y还有UV
    if (planeCount > 1) {
        // 激活UV纹理
        glActiveTexture(GL_TEXTURE);
        // 创建UV-plane纹理
        /*
         CVOpenGLESTextureCacheCreateTextureFromImage
         功能:根据CVImageBuffer创建CVOpenGlESTexture 纹理对象
         参数1: 内存分配器,kCFAllocatorDefault
         参数2: 纹理缓存.纹理缓存将管理纹理的纹理缓存对象
         参数3: sourceImage.
         参数4: 纹理属性.默认给NULL
         参数5: 目标纹理,GL_TEXTURE_2D
         参数6: 指定纹理中颜色组件的数量(GL_RGBA, GL_LUMINANCE, GL_RGBA8_OES, GL_RG, and GL_RED (NOTE: 在 GLES3 使用 GL_R8 替代 GL_RED).)
         参数7: 帧宽度
         参数8: 帧高度
         参数9: 格式指定像素数据的格式
         参数10: 指定像素数据的数据类型,GL_UNSIGNED_BYTE
         参数11: planeIndex
         参数12: 纹理输出新创建的纹理对象将放置在此处。
         */
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixBuffer, NULL, GL_TEXTURE_2D, GL_RG_EXT, width / 2, height / 2, GL_RG_EXT, GL_UNSIGNED_BYTE, 1, &_chromaTexture);
        if (err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFormatImage %d", err);
        }
        
        // 绑定纹理
        glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    // 绑定帧到缓冲区
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    // 设置视口
    glViewport(0, 0, width, height);
    
    // 清理屏幕
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 使用shaderProgram
    glUseProgram(self.program);
    
    // UNIFORM_ROTATION_ANGLE 旋转角度
    glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], 0);
    //UNIFORM_COLOR_CONVERSION_MATRIX YUV->RGB颜色矩阵
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preperredConversion);
    
    //根据视频的方向和纵横比设置四边形顶点
    CGRect viewBounds = self.bounds;
    CGSize contentSize = CGSizeMake(width, height);
    
    CGRect vertexSampLingRect = AVMakeRectWithAspectRatioInsideRect(contentSize, viewBounds);
    
    //标准化规模
    CGSize normalizedSampllingSize = CGSizeMake(0.0, 0.0);
    CGSize cropScaleAmount = CGSizeMake(vertexSampLingRect.size.width / viewBounds.size.width, vertexSampLingRect.size.height / viewBounds.size.height);
    
    // 规范化四元顶点
    if (cropScaleAmount.width > cropScaleAmount.height) {
        normalizedSampllingSize.width = 1.0;
        normalizedSampllingSize.height = cropScaleAmount.height / cropScaleAmount.width;
    } else {
        normalizedSampllingSize.height = 1.0;
        normalizedSampllingSize.width = cropScaleAmount.width / cropScaleAmount.height;
    }
    
    /**
     四个顶点数据定义了我们绘制图像缓冲区的二维平面区域
     使用（-1，-1）和 （1，1）分别作为左下角和右上角坐标形成的顶点数据覆盖整个屏幕
     */
    
    GLfloat quadVertexData[] = {
        -1 * normalizedSampllingSize.width, -1 * normalizedSampllingSize.height,
        normalizedSampllingSize.width, -1 * normalizedSampllingSize.height,
        -1 * normalizedSampllingSize.width, normalizedSampllingSize.height,
        normalizedSampllingSize.width,normalizedSampllingSize.height,
    };
    
    // 更新属性值
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, quadVertexData);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    
    // 纹理顶点的设置使我们垂直翻转纹理，这使我们左上角原点缓冲区匹配OpenGL的左小角纹理坐标系
    CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
    GLfloat quadTextureData[] = {
        CGRectGetMinX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
        CGRectGetMaxX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
        CGRectGetMinX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
        CGRectGetMaxX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
    };
    // 更新纹理坐标属性值
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    // 绘制图形
    glDrawArrays(GL_TRIANGLES, 0, 4);
    
    // 绑定渲染缓存区-> 显示到屏幕
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    // 清理纹理，方便下一帧显示
    [self cleanUpTextures];
    
    // 定期纹理缓存刷新每一帧
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    if (!_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
}

#pragma mark - openGL 相关的设置
- (void)setupGL {
    if (!_context || [EAGLContext setCurrentContext:_context]) {
        return;
    }
    // 设置缓冲区
    [self setupBuffers];
    
    // 加载着色器
    [self landShaders];
    glUseProgram(self.program);
    glUniform1f(uniforms[UNIFORM_Y], 0);
    glUniform1f(uniforms[UNIFORM_UV], 1);
    glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], 0);
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_TRIANGLES, _preperredConversion);
}

- (void)setupBuffers {
    //取消深度测试
    glDisable(GL_DEPTH_TEST);
    
    //打开ATTRIB_VERTEX 属性 position
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    //顶点数据解析方式
    /*
     参数1: 指定从索引0开始取数据，与顶点着色器对应
     参数2: 顶点属性大小
     参数3: 数据类型
     参数4: 归一化
     参数5: 步长（Stride)
     参数6: 数据在缓冲区起始位置的偏移量
     */
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    
    //ATTRIB_TEXCOORD == texCoord
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    
    // 创建Buffer
    [self createBuffers];
}

- (void)createBuffers {
    // 创建帧缓冲区FrameBuffer
    glGenFramebuffers(1, &_frameBufferHandle);
    glBindRenderbuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    // 创建color缓冲区
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    
    // 绑定渲染缓存区
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self];
    
    // 设置缓存区的尺寸
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    // 绑定renderBuffer到frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    
    // 检查frameBuffer状态
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complate franeBuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)releaseBuffers {
    if (_frameBufferHandle) {
        glDeleteFramebuffers(1, &_frameBufferHandle);
        _frameBufferHandle = 0;
    }
    
    if (_colorBufferHandle) {
        glDeleteRenderbuffers(1, &_colorBufferHandle);
        _colorBufferHandle = 0;
    }
}

- (void)resetRenderBuffer {
    if (!_context || [EAGLContext setCurrentContext:_context]) {
        return;
    }
    [self releaseBuffers];
    [self createBuffers];
}

// 清理纹理（Y纹理和UV纹理）
- (void)cleanUpTextures {
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
}

- (BOOL)landShaders {
    GLuint vertShader = 0, fragShader = 0;
    // 创建着色器program
    self.program = glCreateProgram();
    
    //编译片元着色器
    if(![self compileShaderString:&fragShader type:GL_FRAGMENT_SHADER shaderString:shader_fsh]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // 附着顶点着色器到program.
    glAttachShader(self.program, vertShader);
    
    // 附着片元着色器到program.
    glAttachShader(self.program, fragShader);
    
    // 绑定属性位置。这需要在链接之前完成.(让ATTRIB_VERTEX/ATTRIB_TEXCOORD 与position/texCoord产生连接)
    glBindAttribLocation(self.program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(self.program, ATTRIB_TEXCOORD, "texCoord");
    
    // Link the program.
    if (![self linkProgram:self.program]) {
        NSLog(@"Failed to link program: %d", self.program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.program) {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        
        return NO;
    }
    
    //获取uniform的位置
    //Y亮度纹理
    uniforms[UNIFORM_Y] = glGetUniformLocation(self.program, "SamplerY");
    //UV色量纹理
    uniforms[UNIFORM_UV] = glGetUniformLocation(self.program, "SamplerUV");
    //旋转角度preferredRotation
    uniforms[UNIFORM_ROTATION_ANGLE] = glGetUniformLocation(self.program, "preferredRotation");
    //YUV->RGB
    uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(self.program, "colorConversionMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(self.program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(self.program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

//编译shader
- (BOOL)compileShaderString:(GLuint *)shader type:(GLenum)type shaderString:(const GLchar*)shaderString
{
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &shaderString, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    GLint status = 0;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL
{
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        NSLog(@"Failed to load vertex shader: %@", [error localizedDescription]);
        return NO;
    }
    
    const GLchar *source = (GLchar *)[sourceString UTF8String];
    
    return [self compileShaderString:shader type:type shaderString:source];
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    if (!_context || ![EAGLContext setCurrentContext:_context]) {
        return;
    }
    
    [self cleanUpTextures];
    
    if(_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
    }
    
    if (self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
    if(_context) {
        _context = nil;
    }
    
}

#pragma mark -  OpenGL ES 2 shader compilation
//片元着色器代码
const GLchar *shader_fsh = (const GLchar*)"varying highp vec2 texCoordVarying;"
"precision mediump float;"
"uniform sampler2D SamplerY;"
"uniform sampler2D SamplerUV;"
"uniform mat3 colorConversionMatrix;"
"void main()"
"{"
"    mediump vec3 yuv;"
"    lowp vec3 rgb;"
//   Subtract constants to map the video range start at 0
"    yuv.x = (texture2D(SamplerY, texCoordVarying).r - (16.0/255.0));"
"    yuv.yz = (texture2D(SamplerUV, texCoordVarying).rg - vec2(0.5, 0.5));"
"    rgb = colorConversionMatrix * yuv;"
"    gl_FragColor = vec4(rgb, 1);"
"}";

//顶点着色器代码
const GLchar *shader_vsh = (const GLchar*)"attribute vec4 position;"
"attribute vec2 texCoord;"
"uniform float preferredRotation;"
"varying vec2 texCoordVarying;"
"void main()"
"{"
"    mat4 rotationMatrix = mat4(cos(preferredRotation), -sin(preferredRotation), 0.0, 0.0,"
"                               sin(preferredRotation),  cos(preferredRotation), 0.0, 0.0,"
"                               0.0,                        0.0, 1.0, 0.0,"
"                               0.0,                        0.0, 0.0, 1.0);"
"    gl_Position = position * rotationMatrix;"
"    texCoordVarying = texCoord;"
"}";



@end
