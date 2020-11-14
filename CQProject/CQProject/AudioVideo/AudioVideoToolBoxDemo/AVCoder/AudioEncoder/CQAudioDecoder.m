//
//  CQAudioiDecoder.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAudioDecoder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CQAudioConfig.h"

typedef struct {
    char * data;
    UInt32 size;
    UInt32 channelCount;
    AudioStreamPacketDescription    packetDesc;
} CQAudioUserData;

@interface CQAudioDecoder()
@property (nonatomic, strong) NSCondition *converterrCond;
@property (nonatomic, strong) dispatch_queue_t decoderQueue;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

@property (nonatomic) AudioConverterRef audioConverter;
@property (nonatomic) char *aacBuffer;
@property (nonatomic) UInt32 aacBufferSize;
@property (nonatomic) AudioStreamPacketDescription *packetDesc;
@end

@implementation CQAudioDecoder

- (void)dealloc {
    if (_audioConverter) {
        AudioConverterDispose(_audioConverter);
        _audioConverter = NULL;
    }
}

- (instancetype)initWithConfig:(CQAudioConfig *)config {
    if (self = [super init]) {
        self.decoderQueue = dispatch_queue_create("aac.decoder.queue", DISPATCH_QUEUE_SERIAL);
        self.callbackQueue = dispatch_queue_create("aac.decoder.callBack.queue", DISPATCH_QUEUE_SERIAL);
        self.audioConverter = NULL;
        self.aacBufferSize = 0;
        self.aacBuffer = NULL;
        self.config = config;
        if (_config == NULL) {
            _config = [[CQAudioConfig alloc] init];
        }
        AudioStreamPacketDescription desc = {0};
        _packetDesc = &desc;
        [self setupDecoder];
    }
    return  self;
}

- (void)setupDecoder {
    // 输出参数pcm
    AudioStreamBasicDescription outputAudioDes = {0};
    // 采样率
    outputAudioDes.mSampleRate = (Float64)self.config.sampleRete;
    // 输出声道数
    outputAudioDes.mChannelsPerFrame = (UInt32)self.config.channelCount;
    // 输出格式
    outputAudioDes.mFormatID = kAudioFormatLinearPCM;
    // 编码
    outputAudioDes.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked);
    // 每一个packet帧数
    outputAudioDes.mFramesPerPacket = 1;
    // 数据帧中每个通道的采样位数
    outputAudioDes.mBitsPerChannel = 16;
    // 每一帧大小（采样位数 / 8 * 声道数）
    outputAudioDes.mBytesPerFrame = outputAudioDes.mBitsPerChannel / 8 * outputAudioDes.mChannelsPerFrame;
    
    // 对齐方式
    outputAudioDes.mReserved = 0;
    
    // 输入参数aac
    AudioStreamBasicDescription inputAudioDesc = {0};

    
}

- (void)decodeAudioAACData:(NSData *)aacData {
    
}

// 获取解码器类型描述
- (AudioClassDescription *)getAudioCalssDescriptionWithType:(AudioFormatID)type fromManfacture:(uint32_t)manufacture {
    
    return nil;
}
@end
