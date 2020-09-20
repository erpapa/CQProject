//
//  CQCameraStatusView.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CQFlashControl.h"
NS_ASSUME_NONNULL_BEGIN

@interface CQCameraStatusView : UIView
@property (strong, nonatomic) CQFlashControl *flashControl;
@property (strong, nonatomic) UILabel *elapsedTimeLabel;
@end

NS_ASSUME_NONNULL_END
