//
//  CQSystemCapture.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQSystemCapture.h"
@interface CQSystemCapture()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
// 是否在进行捕捉
@property (nonatomic, assign) BOOL isRunning;
// 捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
// 捕捉队列
@property (nonatomic, strong) dispatch_queue_t captureQueue;

// 音频输入设备
@property (nonatomic, strong) AVCaptureDeviceInput *audioInputDevice;
// 音频输出设备
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;

// 视频输入设备
// 当前使用的输入设备
@property (nonatomic, weak) AVCaptureDeviceInput *currentVideoInputDevice;
// 前置摄像头
@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;
// 后置摄像头
@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;
// 输出设备
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureConnection *videoContention;
// 预览
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;
@property (nonatomic, assign) CGSize prelayerSize;
// 捕捉类型
@property (nonatomic, assign) CQSystemCaptureType captureType;

@property (nonatomic, assign, readwrite) NSInteger width;
@property (nonatomic, assign, readwrite) NSInteger height;
@end

@implementation CQSystemCapture
- (instancetype)initWithType:(CQSystemCaptureType)type {
    if (self = [super init]) {
        self.captureType = type;
    }
    return self;
}

- (void)prepare {
    [self prepareWithPreviewSize:CGSizeZero];
}

// 准备捕获视频和音频
- (void)prepareWithPreviewSize:(CGSize)size {
    self.prelayerSize = size;
    if (self.captureType == CQSystemCaptureTypeAudio) {
        [self setupAudio];
    } else if (self.captureType == CQSystemCaptureTypeVideo) {
        [self setupVideo];
    } else if (self.captureType == CQSystemCaptureTypeAll) {
        [self setupAudio];
        [self setupVideo];
    }
}

#pragma mark  start/stop
- (void)start {
    if (!self.isRunning) {
        self.isRunning = YES;
        [self.captureSession startRunning];
    }
}

- (void)stop {
    if (self.isRunning) {
        self.isRunning = NO;
        [self.captureSession stopRunning];
    }
}

- (void)changeCamera {
    [self switchCamera];
}
// 切换摄像头
- (void)switchCamera {
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.currentVideoInputDevice];
    if ([self.currentVideoInputDevice isEqual:self.frontCamera]) {
        self.currentVideoInputDevice = self.backCamera;
    } else {
        self.currentVideoInputDevice = self.frontCamera;
    }
    [self.captureSession addInput:self.currentVideoInputDevice];
    [self.captureSession commitConfiguration];
}

#pragma mark -init Audio/Video
- (void)setupAudio {
    // 获取麦克风设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 将audioDevice 转换为AVCaptureDevice
    self.audioInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    // 音频输出
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    // 设置代理和捕捉队列
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    // 开始配置
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
    }
    if ([self.captureSession canAddOutput:self.audioDataOutput]) {
        [self.captureSession canAddOutput:self.audioDataOutput];
    }
    [self.captureSession commitConfiguration];
    self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (void)setupVideo {
    // 获取所有的video设备
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    // 获取前置摄像头和后置摄像头
    //TODO: 这样获取前置摄像头和后置摄像头是否有问题，需要测试一下
    self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.lastObject error:nil];
    self.backCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.firstObject error:nil];
    // 设置当前设备为前置摄像头
    self.currentVideoInputDevice = self.backCamera;
    // 视频输出
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    // 设置丢弃B帧
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    //kCVPixelBufferPixelFormatTypeKey 指像素的输出格式
    //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange YUV420格式
    [self.videoDataOutput setVideoSettings:@{(__bridge  NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}];
    // 开始配置视频设备
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.currentVideoInputDevice]) {
        [self.captureSession addInput:self.currentVideoInputDevice];
    }
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    // 设置分辨率
    [self setVideoPreset];
    [self.captureSession commitConfiguration];
    
    self.videoContention = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 设置视频输出方向
    self.videoContention.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 设置期望帧率fps
    [self updateFps:25];
    // 设置预览
    [self setupPreviewLayer];
}

- (void)setupPreviewLayer {
    self.preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.preLayer.frame = CGRectMake(0, 0, self.prelayerSize.width, self.prelayerSize.height);
    // 设置满屏
    self.preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.preView.layer addSublayer:self.preLayer];
}

- (void)updateFps:(NSInteger)fps {
    // 获取当前的捕捉设备
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    // 遍历所有设备
    for (AVCaptureDevice *device in videoDevices) {
        // 获取当前支持的最大fps
        float maxRate = [[device.activeFormat.videoSupportedFrameRateRanges firstObject] maxFrameRate];
        // 如果想要设置的fps小于或者等于最大的fps，就精进行修改
        if (maxRate >= fps) {
            if ([device lockForConfiguration:NULL]) {
                device.activeVideoMinFrameDuration = CMTimeMake(10, (int)(fps * 10));
                device.activeVideoMaxFrameDuration = device.activeVideoMinFrameDuration;
                [device unlockForConfiguration];
            }
        }
    }
}

// 设置分辨率
- (void)setVideoPreset {
    //TODO:设置不同的捕捉分辨率
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        self.width = 1920;
        self.height = 1080;
    } else if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        self.width = 1290;
        self.height = 720;
    } else if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]){
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        self.width = 640;
        self.height = 480;
    } else {
        self.captureSession.sessionPreset = AVCaptureSessionPreset352x288;
        self.width = 352;
        self.height = 288;
    }
}

- (void)dealloc {
    [self destoyCaptureSession];
}

// 销毁会话
- (void)destoyCaptureSession {
    if(self.captureSession) {
        if (self.captureType == CQSystemCaptureTypeAudio) {
            [self.captureSession removeInput:self.audioInputDevice];
            [self.captureSession removeOutput:self.audioDataOutput];
        } else if(self.captureType == CQSystemCaptureTypeVideo) {
            [self.captureSession removeInput:self.currentVideoInputDevice];
            [self.captureSession removeOutput:self.videoDataOutput];
        } else if(self.captureType == CQSystemCaptureTypeAll) {
            [self.captureSession removeInput:self.audioInputDevice];
            [self.captureSession removeOutput:self.audioDataOutput];
            [self.captureSession removeInput:self.currentVideoInputDevice];
            [self.captureSession removeOutput:self.videoDataOutput];
        }
        self.captureSession = nil;
    }
}

#pragma mark -输出代理

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == self.audioConnection) {
        [self.delegate captureSampleBuffer:sampleBuffer type:CQSystemCaptureTypeAudio];
    } else if (connection == self.videoContention) {
        [self.delegate captureSampleBuffer:sampleBuffer type:CQSystemCaptureTypeVideo];
    }
}
#pragma mark -授权相关
// 麦克风授权 0 未授权 1，已授权 -1 拒绝授权
// 授权操作是一个异步操作，最好使用一个回调函数比较好
+ (int)checkMicropHoneAuthor {
    int result = 0;
    AVAudioSessionRecordPermission permissStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (permissStatus) {
        case AVAudioSessionRecordPermissionUndetermined:
            // 还未授权
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                
            }];
            result = 0;
            break;;
        case AVAudioSessionRecordPermissionDenied:
            // 拒绝授权
            result = -1;
            break;
        case AVAudioSessionRecordPermissionGranted:
            // 已授权
            result = 1;
            break;
        default:
            break;
    }
    return result;
}

// 摄像头授权 0 未授权 1，已授权 -1 拒绝授权
+ (int)checkCameraAuthor {
    int result = 0;
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoStatus) {
        case AVAuthorizationStatusNotDetermined:
            // 未授权，请求授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
            }];
            break;
        case AVAuthorizationStatusAuthorized:
            result = 1;
            break;
        default:
            result = -1;
            break;
    }
    return result;
}

#pragma mark -懒加载
- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (dispatch_queue_t)captureQueue {
    if (!_captureQueue) {
        _captureQueue = dispatch_queue_create("capture.queue", NULL);
    }
    return _captureQueue;
}

- (UIView *)preView {
    if (!_preView) {
        _preView = [[UIView alloc] init];
    }
    return _preView;
}

@end
