//
//  CQCameraViewController.m
//  CQProject
//
//  Created by CharType on 2020/9/19.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQCameraViewController.h"
#import "CQCameraModel.h"
#import "CQCameeraDefine.h"
#import "CQCameraOverlayView.h"
#import "CQFlashControl.h"
#import "CQPreviewView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CQCameraView.h"

@interface CQCameraViewController ()
@property (nonatomic) CQCameraModeType cameraModeType;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) CQCameraModel *cameraModel;
@property (strong, nonatomic) CQCameraView *cameraView;
@property (strong, nonatomic) UIButton *thumbnailButton;
@end

@implementation CQCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateThumbnail:)
                                                 name:CQThumbnailCreatedNotification
                                               object:nil];
    self.cameraModeType = CQCameraModeTypeVideo;
    self.cameraModel = [[CQCameraModel alloc] init];
    
    NSError *error;
    if ([self.cameraModel setupSession:&error]) {
        [self.cameraView.previewView setSession:self.cameraModel.captureSession];
        [self.cameraModel startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    self.cameraView.previewView.isFocusEnabled = self.cameraModel.cameraSupportsTapToFocus;
    self.cameraView.previewView.isExposeEnabled = self.cameraModel.cameraSupportsTapToExpose;
    
    @weakify(self);
    self.cameraView.previewView.tappedToFocusAtPoint = ^(CGPoint point) {
        @strongify(self);
        [self.cameraModel focusAtPoint:point];
    };
    self.cameraView.previewView.tappedToExposeAtPoint = ^(CGPoint point) {
        @strongify(self);
        [self.cameraModel exposeAtPoint:point];
    };
    self.cameraView.previewView.tappedToResetFocusAndExposurer = ^{
        @strongify(self);
        [self.cameraModel resetFocusAndExposureModes];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)setupViews {
    [self.view addSubview:self.cameraView];
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

- (void)flashControlChanged:(id)sender {
    NSInteger mode = [(CQFlashControl *)sender selectedMode];
    if (self.cameraModeType == CQCameraModeTypePhoto) {
        self.cameraModel.flashMode = mode;
    } else {
        self.cameraModel.torchMode = mode;
    }
}

- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *image = notification.object;
    [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}

- (void)showCameraRoll:(id)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:controller animated:YES completion:nil];
}

- (AVAudioPlayer *)playerWithResource:(NSString *)resourceName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"caf"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    player.volume = 0.1f;
    return player;
}

- (void)cameraModeChanged:(id)sender {
    self.cameraModeType = [sender cameraModel];
}

- (void)swapCameras:(id)sender {
    if ([self.cameraModel switchCameras]) {
        BOOL hidden = NO;
        if (self.cameraModeType == CQCameraModeTypePhoto) {
            hidden = !self.cameraModel.cameraHasFlash;
        } else {
            hidden = !self.cameraModel.cameraHasTorch;
        }
        self.cameraView.controlsView.flashControlHidden = hidden;
        self.cameraView.previewView.isExposeEnabled = self.cameraModel.cameraSupportsTapToExpose;
        self.cameraView.previewView.isFocusEnabled = self.cameraModel.cameraSupportsTapToFocus;
        [self.cameraModel resetFocusAndExposureModes];
    }
}

- (void)captureOrRecord:(UIButton *)sender {
    if (self.cameraModel == CQCameraModeTypePhoto) {
        [self.cameraModel captureStillImage];
    } else {
        if (!self.cameraModel.isRecording) {
            dispatch_async(dispatch_queue_create("com.tapharmonic.kamera", NULL), ^{
                [self.cameraModel startRecording];
                [self startTimer];
            });
        } else {
            [self.cameraModel stopRecording];
            [self stopTimer];
        }
        sender.selected = !sender.selected;
    }
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:[YYWeakProxy proxyWithTarget:self]
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay {
    CMTime duration = self.cameraModel.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    self.cameraView.controlsView.statueView.elapsedTimeLabel.text = timeString;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.cameraView.controlsView.statueView.elapsedTimeLabel.text = @"00:00:00";
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (CQCameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[CQCameraView alloc] init];
    }
    return _cameraView;
}

@end
