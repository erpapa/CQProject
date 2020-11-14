//
//  CQCameraStatusView.m
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQCameraStatusView.h"
@interface CQCameraStatusView() <CQFlashControlDelegate>
@end
@implementation CQCameraStatusView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.flashControl.delegate = self;
}

- (void)flashControlWillExpand {
    [UIView animateWithDuration:0.2f animations:^{
        self.elapsedTimeLabel.alpha = 0.0f;
    }];
}

- (void)flashControlDidCollapse {
    [UIView animateWithDuration:0.1f animations:^{
        self.elapsedTimeLabel.alpha = 1.0f;
    }];
}

- (CQFlashControl *)flashControl {
    if (!_flashControl) {
        _flashControl = [[CQFlashControl alloc] init];
    }
    return _flashControl;
}

- (UILabel *)elapsedTimeLabel {
    if (!_elapsedTimeLabel) {
        _elapsedTimeLabel = [[UILabel alloc] init];
    }
    return _elapsedTimeLabel;
}


@end
