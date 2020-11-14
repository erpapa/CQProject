//
//  CQCameraOverlayView.m
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQCameraOverlayView.h"
@interface CQCameraOverlayView()
@end

@implementation CQCameraOverlayView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super  initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self.modeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)modeChanged:(CQCameraModeView *)modeView {
    BOOL photoModeEnabled = modeView.cameraModeType == CQCameraModeTypePhoto;
    UIColor *toColor = photoModeEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.0f alpha:0.5f];
    CGFloat toOpacity = photoModeEnabled ? 0.0f : 1.0f;
    self.statueView.layer.backgroundColor = toColor.CGColor;
    self.statueView.elapsedTimeLabel.layer.opacity = toOpacity;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.statueView pointInside:[self convertPoint:point toView:self.statueView] withEvent:event] ||
        [self.modeView pointInside:[self convertPoint:point toView:self.modeView] withEvent:event]) {
        return YES;
    }
    return NO;
}

- (void)setFlashControlHidden:(BOOL)state {
    if (_flashControlHidden != state) {
        _flashControlHidden = state;
        self.statueView.flashControl.hidden = state;
    }
}
@end
