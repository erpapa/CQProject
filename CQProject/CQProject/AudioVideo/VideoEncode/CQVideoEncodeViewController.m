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
// 捕捉会话，用于输入输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *captureSession;
// 捕捉输入
@property (nonatomic, strong) AVCaptureInput *captureInput;
// 捕捉输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
// 预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
//帧id
//@property (nonatomic, assign) int frrameId;
// 捕捉队列
@property (nonatomic, strong) dispatch_queue_t captureQueue;
// 编码队列
@property (nonatomic, strong) dispatch_queue_t encodeQueue;

// 写入流数据
@property (nonatomic, strong) NSFileHandle *fileHandele;

@end

@implementation CQVideoEncodeViewController
{
    // 编码session
    VTCompressionSessionRef encodeingSession;
    // 编码格式
    CMFormatDescriptionRef formar;
    int  frameId; //帧ID
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
    // 创建session
    self.captureSession = [[AVCaptureSession alloc] init];
    // 设置捕捉分辨率 分辨率修改测试
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    // 创建队列
    self.captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.encodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    AVCaptureDevice *inputDevice = nil;
//    NSArray *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera,
//                                                                                          AVCaptureDeviceTypeBuiltInTelephotoCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack].devices;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            inputDevice = device;
            break;
        }
    }
    
    // 将设备封装成AVCaptureDeviceInput对象
    self.captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputDevice error:nil];
    // 判断是否能添加设备
    if ([self.captureSession canAddInput:self.captureInput]) {
        [self.captureSession addInput:self.captureInput];
    } else {
        NSLog(@"获取输入设备失败");
        return;
    }
    
    // 配置输出设备
    self.captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 设置最后丢弃的videoFrame未NO
    //TODO:test
    [self.captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    //YUV 4:2:0
    // 设置video的视屏捕捉像素点压缩方式为420
//    [self.captureVideoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}];
    [self.captureVideoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    // 设置捕捉代理和捕捉队列
    [self.captureVideoDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    // 判断是否能添加输出
    if ([self.captureSession canAddOutput:self.captureVideoDataOutput]) {
        [self.captureSession addOutput:self.captureVideoDataOutput];
    } else {
        NSLog(@"输出设备添加失败");
        return;
    }
    // 创建连接
    AVCaptureConnection *connection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 设置视屏捕捉方向
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    // 初始化图层
    self.preViewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    // 设置视屏内容拉伸设置
    [self.preViewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    // 设置图层的fream
    [self.preViewLayer setFrame:CGRectMake(0, 164, self.view.width, self.view.height - 160)];
    
    // 添加图层
    [self.view.layer addSublayer:self.preViewLayer];
    
    // 文件写入沙盒
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"chengqian.h264"];
    // 先移除已经存在的文件
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    // 新建文件
    BOOL createFile = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!createFile) {
        NSLog(@"创建文件失败");
    } else {
        NSLog(@"创建文件成功");
    }
    
    NSLog(@"fileePath = %@", filePath);
    // 初始化FileHandele
    self.fileHandele = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
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
    // 结束VideoToolBox
    [self endVideoToolBox];
    // 关闭文件
    [self.fileHandele closeFile];
    
    self.fileHandele = nil;
}

// 初始化VideToolBox
- (void) initVideoToolBox {
    dispatch_async(self.encodeQueue, ^{
        frameId = 0;
        int width  = 480;
        int height = 640;
        //1.调用VTCompressionSessionCreate创建编码session
        //参数1：NULL 分配器,设置NULL为默认分配
        //参数2：width
        //参数3：height
        //参数4：编码类型,如kCMVideoCodecType_H264
        //参数5：NULL encoderSpecification: 编码规范。设置NULL由videoToolbox自己选择
        //参数6：NULL sourceImageBufferAttributes: 源像素缓冲区属性.设置NULL不让videToolbox创建,而自己创建
        //参数7：NULL compressedDataAllocator: 压缩数据分配器.设置NULL,默认的分配
        //参数8：回调  当VTCompressionSessionEncodeFrame被调用压缩一次后会被异步调用.注:当你设置NULL的时候,你需要调用VTCompressionSessionEncodeFrameWithOutputHandler方法进行压缩帧处理,支持iOS9.0以上
        //参数9：outputCallbackRefCon: 回调客户定义的参考值
        //参数10：compressionSessionOut: 编码会话变量
        OSStatus statusCode = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge  void *)(self), &encodeingSession);
        NSLog(@"H264:VTCompressionSessionCreate:%d",(int)statusCode);
        if (statusCode != 0) {
            return;
        }
        
        
        //设置实时编码输出（避免延迟）
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_ProfileLevel,kVTProfileLevel_H264_Baseline_AutoLevel);
        
        //是否产生B帧(因为B帧在解码时并不是必要的,是可以抛弃B帧的)
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
        
        //设置关键帧（GOPsize）间隔，GOP太小的话图像会模糊
        int frameInterval = 10;
        CFNumberRef frameIntervalRaf = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRaf);
        
        //设置期望帧率，不是实际帧率
        int fps = 10;
        CFNumberRef fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
        
        //码率的理解：码率大了话就会非常清晰，但同时文件也会比较大。码率小的话，图像有时会模糊，但也勉强能看
        //码率计算公式，参考印象笔记
        //设置码率、上限、单位是bps
        int bitRate = width * height * 3 * 4 * 8;
        CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
        
        //设置码率，均值，单位是byte
        int bigRateLimit = width * height * 3 * 4;
        CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bigRateLimit);
        VTSessionSetProperty(encodeingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);
        
        //开始编码
        VTCompressionSessionPrepareToEncodeFrames(encodeingSession);
        
    });
}

- (void)enCode:(CMSampleBufferRef)sampleBuffer {
    // 拿到每一帧未编码的数据
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 设置帧时间，如果不设置会导致时间轴过长
    CMTime presentationTimeStamp = CMTimeMake(frameId++, 1000);
    
    VTEncodeInfoFlags flags;
    
    //参数1：编码会话变量
    //参数2：未编码数据
    //参数3：获取到的这个sample buffer数据的展示时间戳。每一个传给这个session的时间戳都要大于前一个展示时间戳.
    //参数4：对于获取到sample buffer数据,这个帧的展示时间.如果没有时间信息,可设置kCMTimeInvalid.
    //参数5：frameProperties: 包含这个帧的属性.帧的改变会影响后边的编码帧.
    //参数6：ourceFrameRefCon: 回调函数会引用你设置的这个帧的参考值.
    //参数7：infoFlagsOut: 指向一个VTEncodeInfoFlags来接受一个编码操作.如果使用异步运行,kVTEncodeInfo_Asynchronous被设置；同步运行,kVTEncodeInfo_FrameDropped被设置；设置NULL为不想接受这个信息.
    
    OSStatus statusCode = VTCompressionSessionEncodeFrame(encodeingSession, imageBuffer, presentationTimeStamp, kCMTimeInvalid, NULL, NULL, &flags);
    if (statusCode != noErr) {
        NSLog(@"编码失败 code = %d",(int)statusCode);
        VTCompressionSessionInvalidate(encodeingSession);
        CFRelease(encodeingSession);
        encodeingSession = NULL;
        return;
    }
    NSLog(@"一帧数据开始编码");
}


// 编码完成回调
//1.H264硬编码完成后，回调VTCompressionOutputCallback
//2.将硬编码成功的CMSampleBuffer转换成H264码流，通过网络传播
//3.解析出参数集SPS & PPS，加上开始码组装成 NALU。提现出视频数据，将长度码转换为开始码，组成NALU，将NALU发送出去。
void didCompressH264(void *outputCallbackRefCon, void *SourceFrameRefCon,OSStatus status, VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer) {
    NSLog(@"didCompressH264 called with statusCode = %d infoFlags %d", (int)status, (int)infoFlags);
    // 状态错误
    if (status != 0) {
        return;
    }
    // 还没有准备好
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not reeady");
        return;
    }
    CQVideoEncodeViewController *encoder = (__bridge CQVideoEncodeViewController *)outputCallbackRefCon;
    // 判断当前帧是否是关键帧
    // 判断是否是关键帧的步骤
//    CFArrayRef array = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
//    CFDictionaryRef dic = CFArrayGetValueAtIndex(array, 0);
//    bool isKeyFrame = !CFDictionaryContainsKey(dic, kCMSampleAttachmentKey_NotSync);
    bool keyFrame = !CFDictionaryContainsKey(CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0), kCMSampleAttachmentKey_NotSync);
    // 判断当前帧是否是关键帧
    // 获取sps和pps 数据只获取一次 保存在h264文件开头的第一帧中
    // sps (sample per second 采样次数/s)是衡量模数转换是采样速率单位
    if (keyFrame) {
        // 图像存储方式，编码器格式描述
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        
        // sps
        size_t sparameterSetSize,sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
        if (statusCode == noErr) {
            // 获取pps
            size_t pparameterSetSize,pparameterSetCount;
            const uint8_t *pparameterSet;
            
            // 从第一个关键帧获取sps和pps
            OSStatus ppsStatusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            
            // 获取H264参数集合中的SPS和PPS
            if (ppsStatusCode == noErr) {
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                [encoder gotSpsPps:sps pps:pps];
            }
        }
    }
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length,totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVHeaderLength = 4;
        
        // 循环读取nalu的数据
        while (bufferOffset < totalLength - AVHeaderLength) {
            uint32_t NALUnitLength = 0;
            // 读取 一单元长度的nalu
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVHeaderLength);
            
            // 从大端模式转为系统端模式
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            // 获取nalu数据
            NSData *data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset +AVHeaderLength) length:NALUnitLength];
            
            // 将nalu数据写入到文件
            [encoder gotEncodeData:data isKeyFrame:keyFrame];
            // 读取下一个nalu，一次回调可能包含多个nalu的数据
            bufferOffset += AVHeaderLength + NALUnitLength;
        }
    }
}

- (void)gotSpsPps:(NSData *)sps pps:(NSData *)pps {
    NSLog(@"gotSps : %d  pps : %d",(int)[sps length], (int)[pps length]);
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    
    NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
    
    [self.fileHandele writeData:byteHeader];
    [self.fileHandele writeData:sps];
    [self.fileHandele writeData:byteHeader];
    [self.fileHandele writeData:pps];
}

- (void)gotEncodeData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame {
    NSLog(@"gotEncodeData %d",(int)[data length]);
    if (self.fileHandele != NULL) {
        // 添加4个字节的H264协议startCode分隔符
        //一般来说编码器编出的首帧数据为PPS & SPS
        //H264编码时，在每个NAL前添加起始码 0x000001,解码器在码流中检测起始码，当前NAL结束。
        /*
         为了防止NAL内部出现0x000001的数据，h.264又提出'防止竞争 emulation prevention"机制，在编码完一个NAL时，如果检测出有连续两个0x00字节，就在后面插入一个0x03。当解码器在NAL内部检测到0x000003的数据，就把0x03抛弃，恢复原始数据。
         
         总的来说H264的码流的打包方式有两种,一种为annex-b byte stream format 的格式，这个是绝大部分编码器的默认输出格式，就是每个帧的开头的3~4个字节是H264的start_code,0x00000001或者0x000001。
         另一种是原始的NAL打包格式，就是开始的若干字节（1，2，4字节）是NAL的长度，而不是start_code,此时必须借助某个全局的数据来获得编 码器的profile,level,PPS,SPS等信息才可以解码。
         
         */
        const char bytes[] = "\x00\x00\x00\x01";
        // 长度
        size_t length = (sizeof bytes) - 1;
        
        // 头字节
        NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
        // 写入头字节
        [self.fileHandele writeData:byteHeader];
        // 写入h264数据
        [self.fileHandele writeData:data];
    }
}

- (void)endVideoToolBox {
    if (encodeingSession == NULL) {
        return;
    }
    VTCompressionSessionCompleteFrames(encodeingSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(encodeingSession);
    CFRelease(encodeingSession);
    encodeingSession = NULL;
}

#pragma  mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    dispatch_async(self.encodeQueue, ^{
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
