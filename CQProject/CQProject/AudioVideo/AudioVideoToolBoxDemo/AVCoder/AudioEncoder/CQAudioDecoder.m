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
    
    outputAudioDes.mBytesPerPacket = outputAudioDes.mBytesPerFrame * outputAudioDes.mBytesPerPacket;
    // 对齐方式
    outputAudioDes.mReserved = 0;
    
    // 输入参数aac
    AudioStreamBasicDescription inputAudioDesc = {0};
    inputAudioDesc.mSampleRate = (Float64)self.config.sampleRete;
    inputAudioDesc.mChannelsPerFrame = (UInt32)self.config.channelCount;
    inputAudioDesc.mFormatID = kAudioFormatMPEG4AAC;
    inputAudioDesc.mFormatFlags = kMPEG4Object_AAC_LC;
    inputAudioDesc.mFramesPerPacket = 1024;
    
    // 填充输出的相关信息
    UInt32 inDesSize = sizeof(inputAudioDesc);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &inDesSize, &inputAudioDesc);
    
    // 获取解码器的描述信息（只能传入software）
    AudioClassDescription *audioClassDesc = [self getAudioCalssDescriptionWithType:outputAudioDes.mFormatID fromManfacture:kAppleSoftwareAudioCodecManufacturer];
    
    /**
     创建Converter
     参数1 输入音频格式描述
     参数2 输出音频格式描述
     参数3 class Desc 的配置
     参数4 class desc
     参数5 解码器的创建
     */
    OSStatus status = AudioConverterNewSpecific(&inputAudioDesc, &outputAudioDes, 1, audioClassDesc, &_audioConverter);
    if (status != noErr) {
        NSLog(@"Error: 硬解码AAC创建失败 status = %d", (int)status);
        return;
    }
}

- (void)decodeAudioAACData:(NSData *)aacData {
    if (!self.audioConverter) { return; }
    dispatch_async(self.decoderQueue, ^{
        // 记录aac 作为参数传入解码回调函数
        CQAudioUserData userData = {0};
        userData.channelCount = (UInt32)self.config.channelCount;
        userData.data = (char *)[aacData bytes];
        userData.size = (UInt32)aacData.length;
        userData.packetDesc.mDataByteSize = (UInt32)aacData.length;
        userData.packetDesc.mStartOffset = 0;
        userData.packetDesc.mVariableFramesInPacket = 0;
        
        // 输出大小和packet的个数
        UInt32 pcmBufferSize = (UInt32)(2048 * self.config.channelCount);
        UInt32 pcmDataPacketSize = 1024;
        
        // 创建临时容器pcm
        uint8_t *pcmBuffer = malloc(pcmBufferSize);
        memset(pcmBuffer, 0, pcmBufferSize);
        
        
        // 输出Buffer
        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mBuffers[0].mNumberChannels = (uint32_t)self.config.channelCount;
        outAudioBufferList.mBuffers[0].mDataByteSize = (UInt32)pcmBufferSize;
        outAudioBufferList.mBuffers[0].mData = pcmBuffer;
        
        // 输出描述
        AudioStreamPacketDescription outputPacketDesc = {0};
        
        //配置填充函数，获取输出数据
        OSStatus status = AudioConverterFillComplexBuffer(self.audioConverter, &AudioDecoderConverterComplexInputDataProc, &userData, &pcmDataPacketSize, &outAudioBufferList, &outputPacketDesc);
        if (status != noErr) {
            NSLog(@"Error: AAC Decoder error, status=%d",(int)status);
            return;
        }
        
        // 如果获取到数据
        if (outAudioBufferList.mBuffers[0].mDataByteSize > 0) {
            NSData *rawData = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            dispatch_async(self.callbackQueue, ^{
                if ([self.delegate respondsToSelector:@selector(audioDecodeCallback:)]) {
                    [self.delegate audioDecodeCallback:rawData];
                }
            });
        }
        free(pcmBuffer);
    });
}

static OSStatus AudioDecoderConverterComplexInputDataProc(AudioConverterRef inAudioConverter,
                                                          UInt32 *                      ioNumberDataPackets,
                                                          AudioBufferList *               ioData,
                                                          AudioStreamPacketDescription * __nullable * __nullable outDataPacketDescription,
                                                          void * __nullable               inUserData) {
    CQAudioUserData *audioDeCoder = (CQAudioUserData *)inUserData;
    if (audioDeCoder->size <= 0) {
        ioNumberDataPackets = 0;
        return -1;
    }
    
    // 填充数据
    *outDataPacketDescription = &audioDeCoder->packetDesc;
    (*outDataPacketDescription)[0].mStartOffset = 0;
    (*outDataPacketDescription)[0].mDataByteSize = audioDeCoder->size;
    (*outDataPacketDescription)[0].mVariableFramesInPacket = 0;
    
    ioData->mBuffers[0].mData = audioDeCoder->data;
    ioData->mBuffers[0].mDataByteSize = audioDeCoder->size;
    ioData->mBuffers[0].mNumberChannels = audioDeCoder->channelCount;
    return  noErr;;
}

// 获取解码器类型描述
- (AudioClassDescription *)getAudioCalssDescriptionWithType:(AudioFormatID)type fromManfacture:(uint32_t)manufacture {
    static AudioClassDescription desc;
    UInt32 decoderSpecific = type;
    // 获取满足AAC解码器的总大小
    UInt32 size;
    OSStatus status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Decoders, sizeof(decoderSpecific), &decoderSpecific, &size);
    if (status != noErr) {
        NSLog(@"Error 硬解码AAC getInfo 失败 status = %d", (int)status);
        return nil;
    }
    // 计算aac解码器的个数
    unsigned int coutn = size/sizeof(AudioClassDescription);
    // 创建一个包含Count个解码器的数组
    AudioClassDescription description[coutn];
    // 将满足aac编码的解码器信息写入数组
    status = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(decoderSpecific), &decoderSpecific, &size, &description);
    if (status != noErr) {
        NSLog(@"Error : 硬编码AACgetPropert 失败 status = %d", (int)status);
        return nil;
    }
    for (unsigned int i = 0; i < coutn; i++) {
        if (type == description[i].mSubType && manufacture == description[i].mManufacturer) {
            desc = description[i];
            return &desc;
        }
    }
    return nil;
}
@end
