//
//  CQAudioEncoder.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAudioEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CQAudioConfig.h"

@interface CQAudioEncoder()
@property (nonatomic, strong) dispatch_queue_t encoderQueue;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
// 对音频转换器对象
@property (nonatomic, unsafe_unretained) AudioConverterRef audioConverter;
//PCM缓冲区
@property (nonatomic) char *pcmBuffer;
// pcm缓存区大小
@property (nonatomic) size_t pcmBufferSize;
@end

@implementation CQAudioEncoder

- (void)dealloc {
    if (self.audioConverter) {
        AudioConverterDispose(_audioConverter);
        _audioConverter = NULL;
    }
}

- (instancetype)initWithConfig:(CQAudioConfig *)config {
    if (self = [super init]) {
        // 音频编码队列
        self.encoderQueue = dispatch_queue_create("aac hard encoder queue", DISPATCH_QUEUE_SERIAL);
        // 音频回调队列
        self.callbackQueue  = dispatch_queue_create("aac hard encoder callback Queue", DISPATCH_QUEUE_SERIAL);
        // 音频转换器
        self.audioConverter = NULL;
        self.pcmBufferSize = 0;
        _pcmBuffer = NULL;
        self.config = config;
        if (config == nil) {
            self.config = [[CQAudioConfig alloc] init];
        }
    }
    return self;
}

// 编码器回调函数
static OSStatus aacEncodeInputDataProc(AudioConverterRef               inAudioConverter,
                                       UInt32 *                        ioNumberDataPackets,
                                       AudioBufferList *               ioData,
                                       AudioStreamPacketDescription * __nullable * __nullable outDataPacketDescription,
                                       void *  inUserData) {
    CQAudioEncoder *encoder = (__bridge CQAudioEncoder *)(inUserData);
    // 判断pcmBuffersize大小
    if (!encoder.pcmBufferSize) {
        *ioNumberDataPackets = 0;
        return -1;;
    }
    
    // 填充
    ioData->mBuffers[0].mData = encoder.pcmBuffer;
    ioData->mBuffers[0].mDataByteSize = (uint32_t)encoder.pcmBufferSize;
    ioData->mBuffers[0].mNumberChannels = (uint32_t)encoder.config.channelCount;
    
    // 填充完数据后清空数据
    encoder.pcmBufferSize = 0;
    *ioNumberDataPackets = 0;
    return noErr;
}

// 音频编码(当AVFoundation捕获到音频内容之后)
- (void)encodeAudioSamepleBuffer:(CMSampleBufferRef)sampleBuffer {
    CFRetain(sampleBuffer);
    
    // 判断音频转换器是否创建成功，如果没有创建成功，配置音频编码参数，并且创建转码器
    if (self.audioConverter) {
        [self setupEncodeWithSampleBuffer:sampleBuffer];
    }
    
    @weakify(self);
    dispatch_async(self.encoderQueue, ^{
        @strongify(self);
        // 获取CMBlockBuffer，这里面保存了PCM的数据
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        
        // 获取blockBuffer中音频数据大小和音频数据地址
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &_pcmBufferSize, &_pcmBuffer);
        NSError *error = nil;
        if (status != kCMBlockBufferNoErr) {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Error: ACC encode get Data point error:%@", error);
            return;
        }
        
        // 设置_aacBuffer为0
        // 开辟_pcmBuffersize 大小的pcm内存空间
        uint8_t *pcmBuffer = malloc(_pcmBufferSize);
        // 将_pcmBufferSize 数据set到pcmBuffer中
        memset(pcmBuffer, 0, _pcmBufferSize);
        
        //3 输出Buffer
        // 将pcm数据填充到outAudioBufferList 对象中
        AudioBufferList outAduioBufferList = {0};
        outAduioBufferList.mNumberBuffers = 1;
        outAduioBufferList.mBuffers[0].mNumberChannels = (uint32_t)self.config.channelCount;
        outAduioBufferList.mBuffers[0].mDataByteSize = (UInt32)_pcmBufferSize;
        outAduioBufferList.mBuffers[0].mData = pcmBuffer;
        
        // 输出包大小为1
        UInt32 outputDataPacketSize = 1;
        // 配置填充函数，获取输出数据
        status = AudioConverterFillComplexBuffer(_audioConverter, aacEncodeInputDataProc, (__bridge void *)self, &outputDataPacketSize, &outAduioBufferList, NULL);
        
        if (status == noErr) {
            // 获取数据
            NSData *rawAAC = [NSData dataWithBytes:outAduioBufferList.mBuffers[0].mData length:outAduioBufferList.mBuffers[0].mDataByteSize];
            // 释放pcmBuffer
            free(pcmBuffer);
            // 添加ADTS头 写入文件的时候必须添加，获取裸流时需要忽略
//            NSData *adtsHeader = [self adtsDataForPacketlength:rawAAC.length];
//            NSMutableData *fullData = [NSMutableData dataWithCapacity:adtsHeader.length + rawAAC.length];
//            [fullData appendData:adtsHeader];
//            [fullData appendData:rawAAC];
            
            // 将数据传递到回调队列中
            dispatch_async(self.callbackQueue, ^{
                [self.delegate audioEncoderCallBack:rawAAC];
            });
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        CFRelease(blockBuffer);
        CFRelease(sampleBuffer);
        if (error) {
            NSLog(@"error:AAC编码失败 %@",error);
        }
    });
    
}

// 配置音频编码参数
- (void)setupEncodeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // 获取输入参数
    AudioStreamBasicDescription inputAudioDes = *CMAudioFormatDescriptionGetStreamBasicDescription(CMSampleBufferGetFormatDescription(sampleBuffer));
    // 设置输入参数
    AudioStreamBasicDescription outputAudioDes = {0};
    // 设置采样率
    outputAudioDes.mSampleRate = (Float64)_config.sampleRete;
    // 设置输出格式
    outputAudioDes.mFormatID = kAudioFormatMPEG4AAC;
    // 如果设置为0 代表无损编码
    outputAudioDes.mFormatFlags = kMPEG4Object_AAC_LC;
    // 确定每个packet的大小
    outputAudioDes.mBytesPerPacket = 0;
    // 每一个packet祯数 AAC-1024;
    outputAudioDes.mBytesPerPacket = 1024;
    // 每一帧的大小
    outputAudioDes.mBytesPerFrame = 0;
    // 输出声道数
    outputAudioDes.mChannelsPerFrame = (uint32_t)_config.channelCount;
    // 数据帧中每个通道的采样位数
    outputAudioDes.mBitsPerChannel = 0;
    // 对齐方式（8字节对齐）
    outputAudioDes.mReserved = 0;
    
    // 填充输出相关信息
    UInt32 outDesSize = sizeof(outputAudioDes);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &outDesSize, &outputAudioDes);
    
    // 获取编码器的描述信息(只能传入software)
    AudioClassDescription *audioClassDesc = [self getAudioCalssDescriptionWithType:outputAudioDes.mFormatID fromManufacture:kAppleSoftwareAudioCodecManufacturer];
    
    // 创建Converter
    /**
     参数1：输入音频格式描述
     参数2：输出音频格式描述
     参数3：class desc的数量
     参数4：class desc
     参数5：创建的解码器
     */
    OSStatus status = AudioConverterNewSpecific(&inputAudioDes, &outputAudioDes, 1, audioClassDesc, &_audioConverter);
    if (status != noErr) {
        NSLog(@"error 硬编码 创建AAC失败 status = %d",status);
        return;
    }
    
    // 设置硬编码质量
    UInt32 temp = kAudioConverterQuality_High;
    // 编码器呈现质量
    AudioConverterSetProperty(_audioConverter, kAudioConverterCodecQuality, sizeof(temp), &temp);
    
    // 设置比特率
    uint32_t audioBitrate = (uint32_t)self.config.birtrate;
    uint32_t audioBitrateSize= sizeof(audioBitrate);
    status = AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, audioBitrateSize, &audioBitrate);
    if (status != noErr) {
        NSLog(@"error 硬编码AAC 设置比特率失败");
    }
    
}

// 将sampleBuffer数据提取出PCM数据，返回给ViewController 可以直接播放pcm数据
- (NSData *)convertAudioSamepleBufferToPcmData:(CMSampleBufferRef)sampleBuffer {
    // 获取pcm数据大小
    size_t size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
    // 分配空间
    int8_t *audio_data = (int8_t *)malloc(size);
    memset(audio_data, 0, size);
    // 获取CMBlockBuffer.这里面保存了pcm数据
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    // 将数据copy到新分配的空间中
    CMBlockBufferCopyDataBytes(blockBuffer, 0, size, audio_data);
    NSData *data = [NSData dataWithBytes:audio_data length:size];
    free(audio_data);
    return  data;
}

// 获取编码器类型描述
- (AudioClassDescription *)getAudioCalssDescriptionWithType:(AudioFormatID)type fromManufacture:(uint32_t)maufacture {
    static AudioClassDescription desc;
    UInt32 encoderSpecific = type;
    
    // 获取满足AAC编码的总大小
    UInt32 size;
    OSStatus status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderSpecific), &encoderSpecific, &size);
    if (status != noErr) {
        NSLog(@"硬编码AAC get Info失败 status = %d", (int)status);
        return nil;
    }
    
    // 计算aac编码器的个数
    unsigned int count = size / sizeof(AudioClassDescription);
    // 创建一个包含counnt个数编码器的数组
    AudioClassDescription description[count];
    status = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderSpecific), &encoderSpecific, &size, &description);
    if (status != noErr) {
        NSLog(@"Error: 硬编码AAC get proopery 失败， status = %d", (int)status);
        return nil;
    }
    for (unsigned int i = 0; i < count; i++) {
        if (type == description[i].mSubType && maufacture == description[i].mManufacturer) {
            desc = description[i];
            return &desc;
        }
    }
    return nil;
}

- (NSData *)adtsDataForPacketlength:(NSUInteger)packetLength {
    return nil;
}

@end
