//
//  CQPreviewVieew.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQPreviewVieew : UIView
@property (nonatomic, strong) AVCaptureSession *session;
// 是否聚焦
@property (nonatomic, assign) BOOL isFocusEnabled;
// 是否曝光
@property (nonatomic, assign) BOOL isExposeEnabled;
// 聚焦回调
@property (nonatomic, copy) void (^tappedToFocusAtPoint)(CGPoint point);
// 曝光回调
@property (nonatomic, copy) void (^tappedToExposeAtPoint)(CGPoint point);
// 点击重置曝光
@property (nonatomic, copy) void (^tappedToResetFocusAndExposurer)(void);
@end

NS_ASSUME_NONNULL_END
