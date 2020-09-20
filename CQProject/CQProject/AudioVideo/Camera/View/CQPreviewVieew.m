//
//  CQPreviewVieew.m
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
// 预览View

#import "CQPreviewVieew.h"

@interface CQPreviewVieew()
@property (nonatomic, strong) UIView *focusBoxView;
@property (nonatomic, strong) UIView *exposureBoxView;
@property (nonatomic, strong) YYTimer *timer;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleDoubleTapRecognizer;
@end

@implementation CQPreviewVieew
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self superview];
    }
    return self;
}

- (void)setupView {
    // 设置填充模式
    //TODO:test
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self addGestureRecognizer:self.singleTapRecognizer];
    [self addGestureRecognizer:self.doubleTapRecognizer];
    [self addGestureRecognizer:self.doubleDoubleTapRecognizer];
    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    
    [self addSubview:self.focusBoxView];
    [self.focusBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
    }];
    [self addSubview:self.exposureBoxView];
    [self.exposureBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
    }];
}

- (CGPoint)captureDeevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    // 将屏幕上在坐标点转换成摄像头上的坐标点
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (void)runBoxAnimationOnVieew:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

- (void)runResetAnimation {
    if (!self.tappedToFocusAtPoint && !self.tappedToExposeAtPoint) {
        return;
    }
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    CGPoint centerPoint = [previewLayer pointForCaptureDevicePointOfInterest:CGPointMake(0.5f, 0.5f)];
    self.focusBoxView.center = centerPoint;
    self.exposureBoxView.center = centerPoint;
    self.exposureBoxView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusBoxView.hidden = NO;
    self.exposureBoxView.hidden = NO;
    [UIView animateWithDuration:0.15 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.focusBoxView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        self.exposureBoxView.layer.transform = CATransform3DMakeScale(0.7,0.7,1.0);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.focusBoxView.hidden = YES;
            self.exposureBoxView.hidden = YES;
            self.focusBoxView.transform = CGAffineTransformIdentity;
            self.exposureBoxView.transform = CGAffineTransformIdentity;
        });
    }];
}

- (void)setIsFocusEnabled:(BOOL)isFocusEnabled {
    _isFocusEnabled = isFocusEnabled;
    self.singleTapRecognizer.enabled = isFocusEnabled;
}

- (void)setIsExposeEnabled:(BOOL)isExposeEnabled {
    _isExposeEnabled = isExposeEnabled;
    self.doubleTapRecognizer.enabled = isExposeEnabled;
}

#pragma mark - getter

- (UIView *)exposureBoxView {
    if (!_exposureBoxView) {
        _exposureBoxView = [[UIView alloc] init];
        _exposureBoxView.backgroundColor = [UIColor clearColor];
        _exposureBoxView.layer.borderWidth = 5.0;
        _exposureBoxView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.421 blue:0.054 alpha:1.000].CGColor;
        _exposureBoxView.hidden = YES;
        [_exposureBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(150, 150));
        }];
    }
    return _exposureBoxView;
}
- (UIView *)focusBoxView {
    if (!_focusBoxView) {
        _focusBoxView = [[UIView alloc] init];
        _focusBoxView.backgroundColor = [UIColor clearColor];
        _focusBoxView.layer.borderWidth = 5.0;
        _focusBoxView.layer.borderColor = [UIColor colorWithRed:0.102 green:0.636 blue:1.000 alpha:1.000].CGColor;
        _focusBoxView.hidden = YES;
        [_focusBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(150, 150));
        }];
    }
    return _focusBoxView;
}
+ (Class)layerClass {
    //重写这个方法会在创建视图时使用返回的class去创建视图
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    //通过layerr获取到对应的session
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setSession:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (UITapGestureRecognizer *)singleTapRecognizer {
    if (!_singleTapRecognizer) {
        @weakify(self);
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UIGestureRecognizer *guest) {
            @strongify(self);
            CGPoint point = [guest locationInView:self];
            [self runBoxAnimationOnVieew:self.focusBoxView point:point];
            if (self.tappedToFocusAtPoint) {
                self.tappedToFocusAtPoint([self captureDeevicePointForPoint:point]);
            }
        }];
    }
    return _singleTapRecognizer;
}

- (UITapGestureRecognizer *)doubleTapRecognizer {
    if (!_doubleTapRecognizer) {
        @weakify(self);
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *guest) {
            @strongify(self);
            CGPoint point = [guest locationInView:self];
            [self runBoxAnimationOnVieew:self.exposureBoxView point:point];
            if (self.tappedToExposeAtPoint) {
                self.tappedToExposeAtPoint([self captureDeevicePointForPoint:point]);
            }
            
        }];
        _doubleTapRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapRecognizer;
}

- (UITapGestureRecognizer *)doubleDoubleTapRecognizer {
    if (!_doubleDoubleTapRecognizer) {
        @weakify(self);
        _doubleDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self);
            [self runResetAnimation];
            if (self.tappedToResetFocusAndExposurer) {
                self.tappedToResetFocusAndExposurer();
            }
        }];
        _doubleDoubleTapRecognizer.numberOfTapsRequired = 2;
        _doubleDoubleTapRecognizer.numberOfTouchesRequired = 2;
    }
    return _doubleDoubleTapRecognizer;
}

@end
