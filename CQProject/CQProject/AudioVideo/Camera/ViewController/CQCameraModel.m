//
//  CQCameraModel.m
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQCameraModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSFileManager+CQ.h"

NSString *const CQThumbnailCreatedNotification = @"CQThumbnailCreated";

@interface CQCameraModel()<AVCaptureFileOutputRecordingDelegate>
// 视频队列
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong,readwrite) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutPut;
@property (nonatomic, strong) NSURL *outputURL;
@end

@implementation CQCameraModel
- (BOOL)setupSession:(NSError **)error {
    self.captureSession = [[AVCaptureSession alloc] init];
    // 设置图像分辨率
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    // 获取设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 获取输入
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:error];
    // 判断videoInput是否有效
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
    
    // 选择默认音频捕捉设备，返回一个内置的麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        } else {
            return NO;
        }
    } else {
        return NO;
    }
    
    // 从摄像头捕捉静态图片
    self.imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    
    //输出连接，判断是否可用，能用就添加
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    self.movieOutPut = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutPut]) {
        [self.captureSession addOutput:self.movieOutPut];
    }
    self.videoQueue = dispatch_queue_create("chengqian", NULL);
    
    return YES;
}

- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    // 获取可用的视频设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamerra {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
       return device;
}

- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras {
    if ([self canSwitchCameras]) {
        return NO;
    }
    //获取当前设备的反向设备
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamerra];
    //将输入设备封装成AVCaptureDeviceInput
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    //判断videoInput 是否为nil
    if (videoInput) {
        //标注原配置变化开始
        [self.captureSession beginConfiguration];
        
        //将捕捉会话中，原本的捕捉输入设备移除
        [self.captureSession removeInput:self.activeVideoInput];
        
        //判断新的设备是否能加入
        if ([self.captureSession canAddInput:videoInput]) {
            //能加入成功，则将videoInput 作为新的视频捕捉设备
            [self.captureSession addInput:videoInput];
            
            //将获得设备 改为 videoInput
            self.activeVideoInput = videoInput;
        } else {
            //如果新设备，无法加入。则将原本的视频捕捉设备重新加入到捕捉会话中
            [self.captureSession addInput:self.activeVideoInput];
        }
        //配置完成后， AVCaptureSession commitConfiguration 会分批的将所有变更整合在一起。
        [self.captureSession commitConfiguration];
    } else {
        //创建AVCaptureDeviceInput 出现错误，
        if (self.deviceConfigurationFailedWithError) {
            self.deviceConfigurationFailedWithError(error);
        }
        return NO;
    }
    return YES;
}

#pragma mark - Focus Methods 点击聚焦方法的实现
- (BOOL)cameraSupportsTapToFocus {
    //询问激活中的摄像头是否支持兴趣点对焦
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    //是否支持兴趣点对焦 & 是否自动对焦模式
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error;
        //锁定设备准备配置，如果获得了锁
        if ([device lockForConfiguration:&error]) {
            
            //将focusPointOfInterest属性设置CGPoint
            device.focusPointOfInterest = point;
            
            //focusMode 设置为AVCaptureFocusModeAutoFocus
            device.focusMode = AVCaptureFocusModeAutoFocus;
            
            //释放该锁定
            [device unlockForConfiguration];
        } else {
            //错误时，则返回给错误处理代理
            if (self.deviceConfigurationFailedWithError) {
                self.deviceConfigurationFailedWithError(error);
            }
        }
    }
}

#pragma mark - Exposure Methods   点击曝光的方法实现
- (BOOL)cameraSupportsTapToExpose {
    //询问设备是否支持对一个兴趣点进行曝光
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *CQCameraAdjustingExposureContext;
- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode =AVCaptureExposureModeContinuousAutoExposure;
    //判断是否支持 AVCaptureExposureModeContinuousAutoExposure 模式
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        //锁定设备准备配置
        if ([device lockForConfiguration:&error]) {
            //配置期望值
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            //判断设备是否支持锁定曝光的模式。
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                //支持，则使用kvo确定设备的adjustingExposure属性的状态。
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CQCameraAdjustingExposureContext];
            }
            //释放该锁定
            [device unlockForConfiguration];
        } else {
            if (self.deviceConfigurationFailedWithError) {
                self.deviceConfigurationFailedWithError(error);
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    //判断context（上下文）是否为THCameraAdjustingExposureContext
    if (context == &CQCameraAdjustingExposureContext) {
        //获取device
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        //判断设备是否不再调整曝光等级，确认设备的exposureMode是否可以设置为AVCaptureExposureModeLocked
        if(!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            //移除作为adjustingExposure 的self，就不会得到后续变更的通知
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CQCameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    //修改exposureMode
                    device.exposureMode = AVCaptureExposureModeLocked;
                    //释放该锁定
                    [device unlockForConfiguration];
                } else {
                    if (self.deviceConfigurationFailedWithError) {
                        self.deviceConfigurationFailedWithError(error);
                    }
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//重新设置对焦&曝光
- (void)resetFocusAndExposureModes {

    AVCaptureDevice *device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    //获取对焦兴趣点 和 连续自动对焦模式 是否被支持
    BOOL canResetFocus = [device isFocusPointOfInterestSupported]&& [device isFocusModeSupported:focusMode];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    //确认曝光度可以被重设
    BOOL canResetExposure = [device isFocusPointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    //回顾一下，捕捉设备空间左上角（0，0），右下角（1，1） 中心点则（0.5，0.5）
    CGPoint centPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    //锁定设备，准备配置
    if ([device lockForConfiguration:&error]) {
        //焦点可设，则修改
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centPoint;
        }
        //曝光度可设，则设置为期望的曝光模式
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centPoint;
        }
        //释放锁定
        [device unlockForConfiguration];
    } else {
        if (self.deviceConfigurationFailedWithError) {
            self.deviceConfigurationFailedWithError(error);
        }
    }
}



#pragma mark - Flash and Torch Modes    闪光灯 & 手电筒
//判断是否有闪光灯
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}
//闪光灯模式
- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

//设置闪光灯
- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    //获取会话
    AVCaptureDevice *device = [self activeCamera];
    //判断是否支持闪光灯模式
    if ([device isFlashModeSupported:flashMode]) {
        //如果支持，则锁定设备
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            //修改闪光灯模式
            device.flashMode = flashMode;
            //修改完成，解锁释放设备
            [device unlockForConfiguration];
        } else {
            if (self.deviceConfigurationFailedWithError) {
                self.deviceConfigurationFailedWithError(error);
            }
        }
    }
}

//是否支持手电筒
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

//手电筒模式
- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}


//设置是否打开手电筒
- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            if (self.deviceConfigurationFailedWithError) {
                self.deviceConfigurationFailedWithError(error);
            }
        }
    }
}


#pragma mark - Image Capture Methods 拍摄静态图片
/*
    AVCaptureStillImageOutput 是AVCaptureOutput的子类。用于捕捉图片
 */
- (void)captureStillImage {
    //获取连接
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    //程序只支持纵向，但是如果用户横向拍照时，需要调整结果照片的方向
    //判断是否支持设置视频方向
    if (connection.isVideoOrientationSupported) {
        //获取方向值
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    //捕捉静态图片
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable sampleBuffer, NSError * _Nullable error) {
        if (sampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc]initWithData:imageData];
            //重点：捕捉图片成功后，将图片传递出去
            [self writeImageToAssetsLibrary:image];
        }else
        {
            NSLog(@"NULL sampleBuffer:%@",[error localizedDescription]);
        }
    }];
    
    
    
}

//获取方向值
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    //获取UIDevice 的 orientation
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}


/*
    Assets Library 框架
    用来让开发者通过代码方式访问iOS photo
    注意：会访问到相册，需要修改plist 权限。否则会导致项目崩溃
 */

- (void)writeImageToAssetsLibrary:(UIImage *)image {
    //创建ALAssetsLibrary  实例
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    //参数1:图片（参数为CGImageRef 所以image.CGImage）
    //参数2:方向参数 转为NSUInteger
    //参数3:写入成功、失败处理
    [library writeImageToSavedPhotosAlbum:image.CGImage
                             orientation:(NSUInteger)image.imageOrientation
                         completionBlock:^(NSURL *assetURL, NSError *error) {
                             //成功后，发送捕捉图片通知。用于绘制程序的左下角的缩略图
                             if (!error) {
                                 [self postThumbnailNotifification:image];
                             } else {
                                 //失败打印错误信息
                                 id message = [error localizedDescription];
                                 NSLog(@"%@",message);
                             }
                         }];
}

//发送缩略图通知
- (void)postThumbnailNotifification:(UIImage *)image {
    //回到主队列
    dispatch_async(dispatch_get_main_queue(), ^{
        //发送请求
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:CQThumbnailCreatedNotification object:image];
    });
}

#pragma mark - Video Capture Methods 捕捉视频
//判断是否录制状态
- (BOOL)isRecording {
    return self.movieOutPut.isRecording;
}

//开始录制
- (void)startRecording {

    if (![self isRecording]) {
        //获取当前视频捕捉连接信息，用于捕捉视频数据配置一些核心属性
        AVCaptureConnection * videoConnection = [self.movieOutPut connectionWithMediaType:AVMediaTypeVideo];
        //判断是否支持设置videoOrientation 属性。
        if([videoConnection isVideoOrientationSupported]) {
            //支持则修改当前视频的方向
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        //判断是否支持视频稳定 可以显著提高视频的质量。只会在录制视频文件涉及
        if([videoConnection isVideoStabilizationSupported]) {
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
        
        AVCaptureDevice *device = [self activeCamera];
        //摄像头可以进行平滑对焦模式操作。即减慢摄像头镜头对焦速度。当用户移动拍摄时摄像头会尝试快速自动对焦。
        if (device.isSmoothAutoFocusEnabled) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                if (self.deviceConfigurationFailedWithError) {
                    self.deviceConfigurationFailedWithError(error);
                }
            }
        }
        
        //查找写入捕捉视频的唯一文件系统URL.
        self.outputURL = [self uniqueURL];
        //在捕捉输出上调用方法 参数1:录制保存路径  参数2:代理
        [self.movieOutPut startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
    }
}

- (CMTime)recordedDuration {
    return self.movieOutPut.recordedDuration;
}


//写入视频唯一文件系统URL
- (NSURL *)uniqueURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //temporaryDirectoryWithTemplateString  可以将文件写入的目的创建一个唯一命名的目录；
    NSString *dirPath = [fileManager temporaryDirectoryWithTemplateString:@"kamera.XXXXXX"];
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"kamera_movie.mov"];
        return  [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

//停止录制
- (void)stopRecording {
    //是否正在录制
    if ([self isRecording]) {
        [self.movieOutPut stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    //错误
    if (error) {
        if (self.mediaCaptureFailedWithError) {
            self.mediaCaptureFailedWithError(error);
        }
    } else {
        //写入
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    self.outputURL = nil;
}

//写入捕捉到的视频
- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {
    
    //ALAssetsLibrary 实例 提供写入视频的接口
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    //写资源库写入前，检查视频是否可被写入 （写入前尽量养成判断的习惯）
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
        //创建block块
        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;
        completionBlock = ^(NSURL *assetURL,NSError *error) {
            if (error) {
                if (self.assetLibraryWriteFailedWithError) {
                    self.assetLibraryWriteFailedWithError(error);
                }
            } else {
                //用于界面展示视频缩略图
                [self generateThumbnailForVideoAtURL:videoURL];
            }
        };
        //执行实际写入资源库的动作
        [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:completionBlock];
    }
}

//获取视频左下角缩略图
- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    //在videoQueue 上，
    dispatch_async(self.videoQueue, ^{
        //建立新的AVAsset & AVAssetImageGenerator
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        //设置maximumSize 宽为100，高为0 根据视频的宽高比来计算图片的高度
        imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
        //捕捉视频缩略图会考虑视频的变化（如视频的方向变化），如果不设置，缩略图的方向可能出错
        imageGenerator.appliesPreferredTrackTransform = YES;
        //获取CGImageRef图片 注意需要自己管理它的创建和释放
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        //将图片转化为UIImage
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        //释放CGImageRef imageRef 防止内存泄漏
        CGImageRelease(imageRef);
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            //发送通知，传递最新的image
            [self postThumbnailNotifification:image];
            
        });
    });
}

@end
