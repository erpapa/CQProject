//
//  CQVideoEncoder.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQVideoEncoder.h"
#import "CQAudioConfig.h"
#import <VideoToolbox/VideoToolbox.h>

@interface CQVideoEncoder()
// 编码队列
@property (nonatomic, strong) dispatch_queue_t encodeQueue;
// 编码回调队列
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
// 编码会话
@property (nonatomic) VTCompressionSessionRef encodeSession;
// 帧递增标识
@property (nonatomic, assign) long frameId;
// 判断是否已经获取到pps和sps
@property (nonatomic, assign) BOOL hasSpsPps;
@end

@implementation CQVideoEncoder
{
    
}
- (instancetype)initWithConfig:(CQVideoConfig *)config {
    if (self = [super init]) {
        self.config = config;
        self.encodeQueue = dispatch_queue_create("h264.encode.queue", DISPATCH_QUEUE_SERIAL);
        self.callbackQueue = dispatch_queue_create("h264.encode.callback.queue", DISPATCH_QUEUE_SERIAL);
        
        // 编码设置
        // 创建编码会话
        OSStatus status = VTCompressionSessionCreate(kCFAllocatorDefault, (int32_t)self.config.width, (int32_t)self.config.height, kCMVideoCodecType_H264, NULL, NULL, NULL, videoEncodeCallback, (__bridge  void *)self, &_encodeSession);
        if (status != noErr) {
            NSLog(@"VTCompressionSession创建失败 status = %ld", status);
            return self;
        }
        
        // 设置编码器属性
        
        // 设置是否实时执行
        status = VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        NSLog(@"VTSessionSetProperty : set realTime status = %ld", status);
        
        // 指定编码比特流的配置文件和级别，直播一般使用baseline 可减少b帧带来的延时
        status = VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        NSLog(@"VTSessionSetProperty: set PropertyKey_ProfileLevel status = %ld", status);
        
        // 设置码率均值
        CFNumberRef bit = (__bridge CFNumberRef)@(self.config.bitrate);
        status = VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_AverageBitRate, bit);
        NSLog(@"VTSessionSetProperty: set PropertyKey_AverageBitRate status = %ld", status);
        
        // 设置码率限制
        CFArrayRef limits = (__bridge CFArrayRef)@[@(self.config.bitrate / 4), @(self.config.bitrate * 4)];
        status = VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_DataRateLimits, limits);
        NSLog(@"VTSessionSetProperty: set PropertyKey_DataRateLimits status = %ld", status);
        
        // 设置关键帧间隔(GOPSize)GOP太大图像会模糊
        CFNumberRef maxKeyFrameInterval = (__bridge CFNumberRef)@(self.config.fps * 2);
        status = VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, maxKeyFrameInterval);
        NSLog(@"VTSessionSetProperty: set PropertyKey_MaxKeyFrameInterval status = %ld", status);
        
        // 设置fps预期
        CFNumberRef expectedFrameRate = (__bridge CFNumberRef)@(self.config.fps);
        status = VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_ExpectedFrameRate, expectedFrameRate);
        NSLog(@"VTSessionSetProperty: set PropertyKey_ExpectedFrameRate status = %ld", status);
        
        // 准备编码
        status = VTCompressionSessionPrepareToEncodeFrames(_encodeSession);
        NSLog(@"准备开始编码 status = %ld", status);
    }
    return self;
}

- (void)encodeVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // 先持有数据，避免释放
    CFRetain(sampleBuffer);
    dispatch_async(self.encodeQueue, ^{
        // 获取帧数据
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // 当前帧的时间戳
        self.frameId++;
        CMTime timeStamp = CMTimeMake(self.frameId, 1000);
        // 持续时间
        CMTime duration = kCMTimeInvalid;
        // 编码
        VTEncodeInfoFlags flags;
        OSStatus status = VTCompressionSessionEncodeFrame(self.encodeSession, imageBuffer, timeStamp, duration, NULL, NULL, &flags);
        if (status != noErr) {
            NSLog(@"VTCompressionSessionEncodeFrame status = %ld", status);
        }
        //释放数据
        CFRelease(sampleBuffer);
    });
}

const Byte startCode[] = "\x00\x00\x00\x01";
// 编码成功回调
void videoEncodeCallback(void * outputCallbackRefCon,
                         void * sourceFrameRefCon,
                         OSStatus status,
                         VTEncodeInfoFlags infoFlags,
                         CMSampleBufferRef sampleBuffer) {
    if (status != noErr) {
        NSLog(@"videoEncodeCallback encode error, status = %d", (int)status);
        return;
    }
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"videoEncodeCallback data is noReady");
        return;
    }
    CQVideoEncoder *encoder = (__bridge CQVideoEncoder *)outputCallbackRefCon;
    
    // 判断是否是关键帧
    BOOL keyFream = NO;
    CFArrayRef attachArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    keyFream = !CFDictionaryContainsKey(CFArrayGetValueAtIndex(attachArray, 0), kCMSampleAttachmentKey_NotSync);
    
    // 是关键帧并且没有获取到sps和pps
    if (keyFream && !encoder.hasSpsPps) {
        size_t spsSize, spsCount;
        size_t ppsSize, ppsCount;
        const uint8_t *spsData, *ppsData;
        
        // 获取图像源格式
        CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        OSStatus spsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 0, &spsData, &spsSize, &spsCount, 0);
        OSStatus ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 1, &ppsData, &ppsSize, &ppsCount, 0);
        if (spsStatus != noErr && ppsStatus != noErr) {
            NSLog(@"videoEncodeCallback get sps pps success");
            encoder.hasSpsPps = true;
            
            NSMutableData *sps = [NSMutableData dataWithCapacity:4 + spsSize];
            [sps appendBytes:startCode length:4];
            [sps appendBytes:spsData length:spsSize];
            
            NSMutableData *pps = [NSMutableData dataWithCapacity:4 + ppsSize];
            [pps appendBytes:startCode length:4];
            [pps appendBytes:ppsData length:ppsSize];
            dispatch_async(encoder.callbackQueue, ^{
                [encoder.delegate videoEncodeCallBackSps:sps pps:pps];
            });
        } else {
            NSLog(@"videoEncodeCallback: get sps/pps failed spsStatus = %d,ppsStatus = %d",(int)spsStatus, (int)ppsStatus);
        }
    }
    // 获取NALu数据
    size_t lengthAtoffSet,totalLength;
    char *dataPoint;
    
    // 将数据复制到dataPoint
    CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
    OSStatus error = CMBlockBufferGetDataPointer(blockBufferRef, 0, &lengthAtoffSet, &totalLength, &dataPoint);
    if (error != kCMBlockBufferNoErr) {
        NSLog(@"videoEncodeCallback: get dataPoint failed status = %d", (int)error);
        return;
    }
    // 循环获取nalu数据
    size_t offset = 0;
    // 返回的nalu数据前四个字节不是0001的startCode (不是系统端的0001)
    const int lengthInfoSize = 4;
    while (offset < totalLength - lengthInfoSize) {
        uint32_t naluLength = 0;
        // 获取nalu的数据长度
        memcpy(&naluLength, dataPoint + offset, lengthInfoSize);
        // 大端转系统端
        naluLength = CFSwapInt32BigToHost(naluLength);
        // 获取到编码好的视屏数据
        NSMutableData *data = [NSMutableData dataWithCapacity:4 + naluLength];
        [data appendBytes:startCode length:4];
        // 这里append进去的数据到底是什么？
        [data appendBytes:dataPoint + offset + lengthInfoSize length:naluLength];
        
        // 将Nalu数据回调到代理中
        dispatch_async(encoder.callbackQueue, ^{
            [encoder.delegate videoEncodeCallback:data];
        });
        // 移动下标，继续读取下一个数据
        offset += lengthInfoSize + naluLength;
    }
}

- (void)dealloc {
    if(self.encodeSession) {
        VTCompressionSessionCompleteFrames(_encodeSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_encodeSession);
        CFRelease(_encodeSession);
        _encodeSession = NULL;
    }
}

@end
