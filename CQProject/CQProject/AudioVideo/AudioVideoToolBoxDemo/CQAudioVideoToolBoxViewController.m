//
//  CQAudioVideoToolBoxViewController.m
//  CQProject
//
//  Created by CharType on 2020/10/26.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAudioVideoToolBoxViewController.h"
#import "CQSystemCapture.h"
#import "CQAudioConfig.h"
#import "CQAudioEncoder.h"
#import "CQAudioDecoder.h"
#import "CQVideoEncoder.h"
#import "CQVideoDecoder.h"
#import "CQAudioPCMPlayer.h"
#import "CQAEAGLLayer.h"

@interface CQAudioVideoToolBoxViewController ()<CQSystemCaptureDelegate,CQVideoEncoderDelegate,CQAudioEncoderDelegate,CQVideoDecoderDelegate,CQAudioDecoderDelegate>

@property (nonatomic, strong) CQSystemCapture *capture;
@property (nonatomic, strong) CQVideoEncoder *videoEncoder;
@property (nonatomic, strong) CQVideoDecoder *videoDecoder;
@property (nonatomic, strong) CQAudioEncoder *audioEncoder;
@property (nonatomic, strong) CQAudioDecoder *audioDecoder;
@property (nonatomic, strong) CQAudioPCMPlayer *pcmPlayer;
@property (nonatomic, strong) CQAEAGLLayer *displayLayer;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSFileHandle *handle;
// 所有的View
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIStackView *stackView;
@end

@implementation CQAudioVideoToolBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完整编解码";
    [self.view addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(84);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(30);
    }];
    [self setupConfig];
}

- (void)setupConfig {
    self.path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"com.ashaj.h264"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.path]) {
        if ([manager removeItemAtPath:self.path error:nil]) {
            NSLog(@"删除旧的文件成功");
            if ([manager createFileAtPath:self.path contents:nil attributes:nil]) {
                NSLog(@"创建文件成功");
            }
        }
    } else {
        if ([manager createFileAtPath:self.path contents:nil attributes:nil]) {
            NSLog(@"创建文件成功");
        }
    }
    NSLog(@"path = %@",self.path);
    // 创建FileHandle
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.path];
    // 开启权限检测
    [CQSystemCapture checkCameraAuthor];
    
    // 捕获视频
    self.capture = [[CQSystemCapture alloc] initWithType:CQSystemCaptureTypeVideo];
    CGSize size = CGSizeMake(self.view.width / 2, (self.view.height - 124) / 2);
    // 捕获视频的时候传入预览层大小
    [self.capture prepareWithPreviewSize:size];
    self.capture.preView.frame = CGRectMake(0, 124, size.width, size.height);
    [self.view addSubview:self.capture.preView];
    self.capture.delegate = self;
    
    CQVideoConfig *videoConfig = [CQVideoConfig defaultConfig];
    videoConfig.width = self.capture.width;
    videoConfig.height = self.capture.height;
    videoConfig.bitrate = videoConfig.width * videoConfig.height * 5;
    
    self.videoEncoder = [[CQVideoEncoder alloc] initWithConfig:videoConfig];
    self.videoEncoder.delegate = self;
    self.videoDecoder = [[CQVideoDecoder alloc] initWithConfig:videoConfig];
    self.videoDecoder.delegate = self;
    
    self.audioEncoder = [[CQAudioEncoder alloc] initWithConfig:[CQAudioConfig defaultConfig]];
    self.audioEncoder.delegate = self;
    
    self.audioDecoder = [[CQAudioDecoder alloc] initWithConfig:[CQAudioConfig defaultConfig]];
    self.audioDecoder.delegate = self;
    
    self.pcmPlayer = [[CQAudioPCMPlayer alloc] initWithConfig:[CQAudioConfig defaultConfig]];
    
    self.displayLayer = [[CQAEAGLLayer alloc] initWithFrame:CGRectMake(size.width, 124, size.width, size.height)];
    [self.view.layer addSublayer:self.displayLayer];
}

- (void)startCapture {
    [self.capture start];
}

- (void)stopCapture {
    [self.capture stop];
}

- (void)closeFile {
    [self.handle closeFile];
}

#pragma  mark - delegate
// 捕获音视频回调
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type:(CQSystemCaptureType)type {
    if (type == CQSystemCaptureTypeAudio) {
        // 1.直接播放数据
//        NSData *pcmData = [self.audioEncoder convertAudioSamepleBufferToPcmData:sampleBuffer];
//        [self.pcmPlayer playPCMData:pcmData];
        
        // 2.AAC编码
        [self.audioEncoder encodeAudioSamepleBuffer:sampleBuffer];
    } else if (type == CQSystemCaptureTypeVideo) {
        [self.videoEncoder encodeVideoSampleBuffer:sampleBuffer];
    }
}

// aac编码回调
- (void)audioEncoderCallBack:(NSData *)aacData {
    // 1. 写入文件
//    [self.handle seekToEndOfFile];
//    [self.handle writeData:aacData];
    
    // 2. 直接解码
    [self.audioDecoder decodeAudioAACData:aacData];
}

// h264编码回调
- (void)videoEncodeCallBackSps:(NSData *)sps pps:(NSData *)pps {
    // 写入文件
//    [self.handle seekToEndOfFile];
//    [self.handle writeData:sps];
//    [self.handle seekToEndOfFile];
//    [self.handle writeData:pps];
    // 解码
    [self.videoDecoder decodeNaluData:sps];
    [self.videoDecoder decodeNaluData:pps];
}

- (void)videoEncodeCallback:(NSData *)h264Data {
    // 写入文件
//    [self.handle seekToEndOfFile];
//    [self.handle writeData:h264Data];
    
    // 直接解码
    [self.videoDecoder decodeNaluData:h264Data];
}

- (void)videoDecodeCallback:(CVPixelBufferRef)imageBuffer {
    if (imageBuffer) {
        self.displayLayer.pixelBuffer = imageBuffer;
    }
}

#pragma  mark - getter
- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.startButton, self.stopButton,self.closeButton]];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentFill;
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
    }
    return _stackView;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [[UIButton alloc] init];
        [_startButton setTitle:@"开始编码" forState:UIControlStateNormal];
        _startButton.layer.cornerRadius = 15;
        _startButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _startButton.layer.masksToBounds = YES;
        [_startButton setBackgroundColor:[UIColor orangeColor]];
        [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        @weakify(self);
        [_startButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self);
            [self startCapture];
        }];
    }
    return _startButton;;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [[UIButton alloc] init];
        [_stopButton setTitle:@"停止编码" forState:UIControlStateNormal];
        _stopButton.layer.cornerRadius = 15;
        _stopButton.layer.masksToBounds = YES;
        _stopButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_stopButton setBackgroundColor:[UIColor orangeColor]];
        [_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        @weakify(self);
        [_stopButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self);
            [self stopCapture];
        }];
    }
    return _stopButton;;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setTitle:@"关闭文件" forState:UIControlStateNormal];
        _closeButton.layer.cornerRadius = 15;
        _closeButton.layer.masksToBounds = YES;
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_closeButton setBackgroundColor:[UIColor orangeColor]];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        @weakify(self);
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self);
            [self closeFile];
        }];
    }
    return _closeButton;
}

@end
