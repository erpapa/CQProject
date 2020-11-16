//
//  CQAudioPCMPlayer.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAudioPCMPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "CQAudioConfig.h"

#define MIN_Size_PER_FRAME 2048 // 每帧最小的数据长度
static const int kNumberBuffers_play = 3;
typedef struct AQPlayerState {
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers_play];
    AudioStreamPacketDescription   *mPacketDesc;
} AQPlayerState;

@interface CQAudioPCMPlayer()
@property (nonatomic, assign) AQPlayerState aqps;
@property (nonatomic, strong)CQAudioConfig *config;
@property (nonatomic, assign) BOOL isPlaying;
@end

@implementation CQAudioPCMPlayer
- (void)dispose {
    AudioQueueStop(_aqps.mQueue, true);
    AudioQueueDispose(_aqps.mQueue, true);
}

- (instancetype)initWithConfig:(CQAudioConfig *)config {
    self = [super init];
    if (self) {
        self.config = config;
        // 配置
        AudioStreamBasicDescription dataFormat = {0};
        dataFormat.mSampleRate = (Float64)self.config.sampleRete;
        // 输出声道数
        dataFormat.mChannelsPerFrame = (UInt32)self.config.channelCount;
        // 输出格式
        dataFormat.mFormatID = kAudioFormatLinearPCM;
        dataFormat.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked);
        // 每一个packet帧数
        dataFormat.mFramesPerPacket = 1;
        // 数据帧中每个通道采样位数
        dataFormat.mBitsPerChannel = 16;
        dataFormat.mBytesPerFrame = dataFormat.mBitsPerChannel / 8 * dataFormat.mChannelsPerFrame;
        dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame * dataFormat.mFramesPerPacket;
        dataFormat.mReserved = 0;
        AQPlayerState state = {0};
        state.mDataFormat = dataFormat;
        _aqps = state;
        [self setupSession];
        
        
        OSStatus status = AudioQueueNewOutput(&_aqps.mDataFormat, TMAudioQueueOutoutCallback, NULL, NULL, NULL,0, &_aqps.mQueue);
        if (status != noErr) {
            NSError *error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Error AudoQueue create error =%@", [error description]);
            return self;
        }
        [self setupVoice:1];
        self.isPlaying = false;
    }
    return self;
}

static void TMAudioQueueOutoutCallback(void * __nullable       inUserData,
                                       AudioQueueRef           inAQ,
                                       AudioQueueBufferRef     inBuffer) {
    AudioQueueFreeBuffer(inAQ, inBuffer);
}

- (void)setupSession {
    NSError *error = nil;
    // 将会话设置为活动或者非活动，激活音频会话是一个同步阻塞的操作
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Error:audioQueue palyer AVAudioSession error %@",[error description]);
    }
    // 设置会话类型
    error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error: audioQueue palyer AVAudioSession error, error:%@",error);
    }
}

- (void)playPCMData:(NSData *)data {
    // 指向音频队列缓冲区
    AudioQueueBufferRef inBuffer;
    
    // 参数1要分配缓冲区的音频队列
    // 新缓冲区所需要的容量
    // 输出指向新分配的音频队列缓冲区
    AudioQueueAllocateBuffer(_aqps.mQueue, MIN_Size_PER_FRAME, &inBuffer);
    
    memcpy(inBuffer->mAudioData, data.bytes, data.length);
    // 设置inBuffer.mAudioDataBytes
    inBuffer->mAudioDataByteSize = (UInt32)data.length;
    
    // 将缓冲区添加到录制或播放音频队列的缓冲区队列
    /**
     参数1:拥有音频队列缓冲区的音频队列
     参数2:要添加到缓冲区队列的音频队列缓冲区。
     参数3:inBuffer参数中音频数据包的数目,对于以下任何情况，请使用值0：
            * 播放恒定比特率（CBR）格式时。
            * 当音频队列是录制（输入）音频队列时。
            * 当使用audioqueueallocateBufferWithPacketDescriptions函数分配要重新排队的缓冲区时。在这种情况下，回调应该描述缓冲区的mpackedDescriptions和mpackedDescriptionCount字段中缓冲区的数据包。
     参数4:一组数据包描述。对于以下任何情况，请使用空值
            * 播放恒定比特率（CBR）格式时。
            * 当音频队列是输入（录制）音频队列时。
            * 当使用audioqueueallocateBufferWithPacketDescriptions函数分配要重新排队的缓冲区时。在这种情况下，回调应该描述缓冲区的mpackedDescriptions和mpackedDescriptionCount字段中缓冲区的数据包
     */
    OSStatus status = AudioQueueEnqueueBuffer(_aqps.mQueue, inBuffer, 0, NULL);
    if (status != noErr) {
        NSLog(@"Error: audio queue palyer enqueue error:%d",(int)status);
    }
    
    // 开始播放或者录制音频
    // 传入音频队列和开始时间
    AudioQueueStart(_aqps.mQueue,NULL);
}

- (void)setupVoice:(Float32)gain {
    Float32 gain0 = gain;
    if (gain < 0) {
        gain0 = 0;
    } else if (gain > 1) {
        gain0 =  1;
    }
    // 设置播放音频队列参数
    AudioQueueSetParameter(_aqps.mQueue, kAudioQueueParam_Volume, gain0);
}
@end
