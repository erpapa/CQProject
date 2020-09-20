//
//  CQCameeraView.m
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQCameraView.h"
#import "CQPreviewView.h"
#import "CQCameraOverlayView.h"

@interface CQCameraView()
@end

@implementation CQCameraView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.previewView];
        [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.width.equalTo(self);
        }];
        [self addSubview:self.controlsView];
        [self.controlsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.width.equalTo(self);
        }];
    }
    return self;
}

- (CQPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[CQPreviewView alloc] init];
    }
    return _previewView;
}

- (CQCameraOverlayView *)controlsView {
    if (!_controlsView) {
        _controlsView = [[CQCameraOverlayView alloc] init];
    }
    return _controlsView;
}
@end
