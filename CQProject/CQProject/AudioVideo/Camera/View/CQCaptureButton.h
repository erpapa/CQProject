//
//  CQCaptureButton.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CQCameeraDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CQCaptureButton : UIButton
+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(CQCameraModeType)captureButtonMode;
@property (nonatomic, assign) CQCameraModeType buttonModeType;
@end

NS_ASSUME_NONNULL_END
