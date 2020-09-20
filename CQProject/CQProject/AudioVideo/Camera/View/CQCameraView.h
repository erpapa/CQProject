//
//  CQCameeraView.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CQPreviewView,CQCameraOverlayView;

NS_ASSUME_NONNULL_BEGIN

@interface CQCameraView : UIView
@property (strong, nonatomic) CQPreviewView *previewView;
@property (strong, nonatomic) CQCameraOverlayView *controlsView;
@end

NS_ASSUME_NONNULL_END
