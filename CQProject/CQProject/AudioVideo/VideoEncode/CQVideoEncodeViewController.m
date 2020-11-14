//
//  CQVideoEncodeViewController.m
//  CQProject
//
//  Created by CharType on 2020/10/2.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQVideoEncodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

@interface CQVideoEncodeViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) UIButton *button;
// 捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
// 捕捉输入
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
// 捕捉输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
// 预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@end

@implementation CQVideoEncodeViewController
{
    // 帧id
    int frameId;
    // 捕捉队列
    dispatch_queue_t captureQueue;
    // 编码队列
    dispatch_queue_t encodeQueue;
    // 编码session
    VTCompressionSessionRef encodeingSession;
    // 编码格式
    CMFormatDescriptionRef format;
    // 写入文件
    NSFileHandle *fileHandele;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频编码";
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(200);
        make.top.equalTo(self.view).offset(64);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
}

// 开始捕捉
- (void)startCapture {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    encodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    AVCaptureDevice *inputCamera = nil;
    // 获取iPhone摄像头捕捉设备， 前置摄像头，后置摄像头
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            inputCamera = device;
        }
    }
    
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    // 判断是否能加入后置摄像头作为输入设备
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    // 配置输出设备
    self.captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 设置丢弃B帧
    [self.captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    // 设置捕捉的像素点压缩方式为4：2:0
    
    [self.captureVideoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    // 设置捕捉代理和捕捉队列
    [self.captureVideoDataOutput setSampleBufferDelegate:self queue:captureQueue];
    // 添加输出
    if ([self.captureSession canAddOutput:self.captureVideoDataOutput]) {
        [self.captureSession addOutput:self.captureVideoDataOutput];
    }
    // 创建连接
    AVCaptureConnection *connection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    // 设置视屏捕捉方向
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    // 初始化图层
    self.preViewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    // 设置视屏裁剪？
    [self.preViewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    // 设置图层fream
    [self.preViewLayer setFrame:CGRectMake(0, 100, self.view.width, self.view.height - 100)];
    // 添加图层
    [self.view.layer addSublayer:self.preViewLayer];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"chengqian.h264"];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    // 新建文件
    BOOL createFile = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!createFile) {
        NSLog(@"create file failed");
    } else {
        NSLog(@"create file success");
    }
    
    NSLog(@"filePath = %@",filePath);
    fileHandele = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    // 初始化videoToolBox
    [self initVideoToolBox];
    
    // 开始捕捉
    [self.captureSession startRunning];
}

- (void)stopCapture {
    // 停止捕捉
    [self.captureSession stopRunning];
    // 移除预览图层
    [self.preViewLayer removeFromSuperlayer];
    // 借宿videoToolBox
    [self endVideoToolBox];
    // 关闭文件
    [fileHandele closeFile];
    fileHandele = nil;
}

// 初始化VideToolBox
- (void) initVideoToolBox {
    dispatch_sync(encodeQueue, ^{
        frameId = 0;
        int width = 480,height = 640;
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self), &encodeingSession);
        if (status != 0) {
            NSLog(@"H264:Unable to create a H264 session");
            return;
        }
        
        // 设置是实时编码输出 避免延迟
        VTSessionSetProperty(encodeingSession,kVTCompressionPropertyKey_RealTime,kCFBooleanTrue);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        
        //是否产生B帧(因为B帧在解码时并不是必要的,是可以抛弃B帧的)
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
        
        // 设置关键帧
        int frameInterval = 10;
        CFNumberRef frameIntervalRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType, &frameInterval);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
        
        // 设置期望帧率
        int fps = 10;
        CFNumberRef fpsRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType, &fps);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
        
        // 设置码率上限
        int bitRate = width * height * 3 * 4 * 8;
        CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type, &bitRate);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
        
        // 设置码率均值
        int bigRateLimit = width * height * 3 * 4;
        CFNumberRef bitRateLieitRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type, &bigRateLimit);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLieitRef);
        
        // 开始编码
        VTCompressionSessionPrepareToEncodeFrames(encodeingSession);
    });
}

- (void)enCode:(CMSampleBufferRef)sampleBuffer {
    // 获取到每一帧未编码的数据
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    // 设置帧时间
    CMTime presentationTimeStamp = CMTimeMake(frameId++, 1000);
    VTEncodeInfoFlags flags;
    OSStatus statusCode = VTCompressionSessionEncodeFrame(encodeingSession, imageBuffer,presentationTimeStamp,kCMTimeInvalid,NULL,NULL,&flags);
    if (statusCode != noErr) {
        VTCompressionSessionInvalidate(encodeingSession);
        CFRelease(encodeingSession);
        encodeingSession = NULL;
        return;
    }
    NSLog(@"H264编码成功");
}


// 编码完成回调
//1.H264硬编码完成后，回调VTCompressionOutputCallback
//2.将硬编码成功的CMSampleBuffer转换成H264码流，通过网络传播
//3.解析出参数集SPS & PPS，加上开始码组装成 NALU。提现出视频数据，将长度码转换为开始码，组成NALU，将NALU发送出去。
void didCompressH264(void *outputCallbackRefCon, void *SourceFrameRefCon,OSStatus status, VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer) {
    NSLog(@"didCompressH264 called with status %d infoFlags %d",(int)status,(int)infoFlags);
    if (status != 0) {
        return;
    }
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready");
        return;
    }
    CQVideoEncodeViewController *encoder = (__bridge CQVideoEncodeViewController *)outputCallbackRefCon;
    // 判断当前帧是否是关键帧
    
    bool keyFrame = !CFDictionaryContainsKey(CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0), kCMSampleAttachmentKey_NotSync);
    if (keyFrame) {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize,sparaneterSetCount;
        const uint8_t *sparameterSet;
        OSStatus spsStatusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparaneterSetCount, 0);
        if (spsStatusCode == noErr) {
            // 获取pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            // 从第一个关键帧获取sps和pps
            OSStatus ppsStatusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            if (ppsStatusCode == noErr) {
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder) {
                    [encoder gotSpsPps:sps pps:pps];
                }
            }
        }
    }
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length,totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCQheaderLength = 4;
        
        // 循环获取nalu数据
        while (bufferOffset < totalLength - AVCQheaderLength) {
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCQheaderLength);
            // 从大端模式转换为系统端模式
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            //获取nalu数据
            NSData *data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCQheaderLength) length:NALUnitLength];
            
            [encoder gotEncodeData:data isKeyFrame:keyFrame];
            
            bufferOffset += AVCQheaderLength + NALUnitLength;
        }
    }
}

- (void)gotSpsPps:(NSData *)sps pps:(NSData *)pps {
    const char bytes[] = "\0x00\0x00\0x00\0x01";
    size_t length = (sizeof bytes) - 1;
    NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
    [fileHandele writeData:byteHeader];
    [fileHandele writeData:sps];
    [fileHandele writeData:byteHeader];
    [fileHandele writeData:pps];
    
}

- (void)gotEncodeData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame {
    if (fileHandele != NULL) {
        const char bytes[] = "\0x00\0x00\0x00\0x01";
        size_t length = (sizeof bytes) - 1;
        NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
        [fileHandele writeData:byteHeader];
        [fileHandele writeData:data];
    }
}

- (void)endVideoToolBox {
    VTCompressionSessionCompleteFrames(encodeingSession,kCMTimeInvalid);
    VTCompressionSessionInvalidate(encodeingSession);
    CFRelease(encodeingSession);
    encodeingSession = NULL;
}

#pragma  mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    dispatch_sync(encodeQueue, ^{
        [self enCode:sampleBuffer];
    });
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setTitle:@"play" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setBackgroundColor:[UIColor orangeColor]];
        @weakify(self);
        [_button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self);
            // 先判断是否在捕捉
            if (!self.captureSession || !self.captureSession.isRunning) {
                [self startCapture];
                [self.button setTitle:@"Stop" forState:UIControlStateNormal];
            } else {
                [self.button setTitle:@"play" forState:UIControlStateNormal];
                [self stopCapture];
            }
        }];
    }
    return _button;
}

@end
