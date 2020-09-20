//
//  CQCameraModel.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const CQThumbnailCreatedNotification;

@interface CQCameraModel : NSObject
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
// 摄像头数量
@property (nonatomic, readonly) NSUInteger cameraCount;
// 是否支持手电筒
@property (nonatomic, readonly) BOOL cameraHasTorch;
// 是否支持闪光灯
@property (nonatomic, readonly) BOOL cameraHasFlash;
// 是否支持聚焦
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus;
// 是否支持曝光
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;
// 手电筒模式
@property (nonatomic) AVCaptureTorchMode torchMode;
// 闪光灯模式
@property (nonatomic) AVCaptureFlashMode flashMode;

// 出错回调 配置错误
@property (nonatomic, copy) void  (^deviceConfigurationFailedWithError)(NSError *error);
// 媒体数据错误
@property (nonatomic, copy) void  (^mediaCaptureFailedWithError)(NSError *error);
// 写入文件回调错误
@property (nonatomic, copy) void  (^assetLibraryWriteFailedWithError)(NSError *error);
// 初始化session
- (BOOL)setupSession:(NSError **)error;
// 开始
- (void)startSession;
// 停止
- (void)stopSession;
// 3 切换不同的摄像头
- (BOOL)switchCameras;
// 是否支持切换摄像头
- (BOOL)canSwitchCameras;
// 聚焦方法
- (void)focusAtPoint:(CGPoint)point;
// 曝光方法
- (void)exposeAtPoint:(CGPoint)point;
// 重设聚焦曝光方法
- (void)resetFocusAndExposureModes;

// 捕捉静态图片
- (void)captureStillImage;

// 视频录制
// 开始录制
- (void)startRecording;

// 停止录制
- (void)stopRecording;

// 获取录制状态
- (BOOL)isRecording;

// 获取录制时间
- (CMTime)recordedDuration;

@end

NS_ASSUME_NONNULL_END
