//
//  CQCaptureButton.m
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQCaptureButton.h"

//@interface CQPhotoCaptureButton : CQCaptureButton;
//
//@end
//
//@interface CQVideoCaptureButton : CQPhotoCaptureButton;
//
//@end

@interface CQCaptureButton()
@property (nonatomic, strong) CALayer *circleLayer;
@end

@implementation CQCaptureButton
+ (instancetype)captureButton {
    return [[self alloc] initWithCaptureButtonMode:CQCameraModeTypeVideo];
}

+ (instancetype)captureButtonWithMode:(CQCameraModeType)mode {
    return [[self alloc] initWithCaptureButtonMode:mode];
}

- (id)initWithCaptureButtonMode:(CQCameraModeType)mode {
    self = [super initWithFrame:CGRectMake(0, 0, 68, 68)];
    if (self) {
        _buttonModeType = mode;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    UIColor *circleColor = (self.buttonModeType == CQCameraModeTypeVideo) ? [UIColor redColor] : [UIColor whiteColor];
    _circleLayer = [CALayer layer];
    _circleLayer.backgroundColor = circleColor.CGColor;
    _circleLayer.bounds = CGRectInset(self.bounds, 8.0, 8.0);
    _circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _circleLayer.cornerRadius = _circleLayer.bounds.size.width / 2.0f;
    [self.layer addSublayer:_circleLayer];
}

- (void)setCaptureButtonMode:(CQCameraModeType)mode {
    if (_buttonModeType != mode) {
        _buttonModeType = mode;
        UIColor *toColor = (mode == CQCameraModeTypeVideo) ? [UIColor redColor] : [UIColor whiteColor];
        self.circleLayer.backgroundColor = toColor.CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeAnimation.duration = 0.2f;
    if (highlighted) {
        fadeAnimation.toValue = @0.0f;
    } else {
        fadeAnimation.toValue = @1.0f;
    }
    self.circleLayer.opacity = [fadeAnimation.toValue floatValue];
    [self.circleLayer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.buttonModeType == CQCameraModeTypeVideo) {
        [CATransaction disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        if (selected) {
            scaleAnimation.toValue = @0.6f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 4.0f);
        } else {
            scaleAnimation.toValue = @1.0f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 2.0f);
        }
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, radiusAnimation];
        animationGroup.beginTime = CACurrentMediaTime() + 0.2f;
        animationGroup.duration = 0.35f;
        
        [self.circleLayer setValue:radiusAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
        
        [self.circleLayer addAnimation:animationGroup forKey:@"scaleAndRadiusAnimation"];
    }
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 6.0);
    CGRect insetRect = CGRectInset(rect, 6.0 / 2.0f, 6.0 / 2.0f);
    CGContextStrokeEllipseInRect(context, insetRect);
}

@end
