//
//  CQCameeraView.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CQPreviewVieew.h"
#import "CQCameraOverlayView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CQCameraView : UIView
@property (strong, nonatomic) CQPreviewVieew *previewView;
@property (strong, nonatomic) CQCameraOverlayView *controlsView;
@end

NS_ASSUME_NONNULL_END
