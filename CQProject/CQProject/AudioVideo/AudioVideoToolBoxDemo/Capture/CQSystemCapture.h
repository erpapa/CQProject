//
//  CQSystemCapture.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, CQSystemCaptureType) {
    CQSystemCaptureTypeVideo = 0,
    CQSystemCaptureTypeAudio,
    CQSystemCaptureTypeAll
};

@protocol CQSystemCaptureDelegate <NSObject>
@optional
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type:(CQSystemCaptureType)type;
@end


@interface CQSystemCapture : NSObject
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, weak) id<CQSystemCaptureDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger width;
@property (nonatomic, assign, readonly) NSInteger height;
- (instancetype)initWithType:(CQSystemCaptureType)type;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
// 准备工作，只获取音频时候调用
- (void)prepare;
// 捕获内容包括视频的时候来调用。添加到View上来显示
- (void)prepareWithPreviewSize:(CGSize)size;
// 开始捕获
- (void)start;
// 停止捕获
- (void)stop;
// 切换摄像头
- (void)changeCamera;
// 授权检测
+ (int)checkMicropHoneAuthor;
+ (int)checkCameraAuthor;
@end

