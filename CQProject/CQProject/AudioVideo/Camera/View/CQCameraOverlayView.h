//
//  CQCameraOverlayView.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CQCameraModeView.h"
#import "CQCameraStatusView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CQCameraOverlayView : UIView
@property (nonatomic, strong) CQCameraModeView *modeView;
@property (nonatomic, strong) CQCameraStatusView *statueView;
@property (nonatomic, assign) BOOL flashControlHidden;

@end

NS_ASSUME_NONNULL_END
