//
//  CQVideoDecoder.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQVideoDecoder.h"
#import "CQAudioConfig.h"
#import <VideoToolbox/VideoToolbox.h>

@interface CQVideoDecoder()
@property (nonatomic, strong) dispatch_queue_t decodeQueue;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
// 解码会话
@property (nonatomic) VTDecompressionSessionRef decodeSession;
@property (nonatomic, assign) uint8_t sps;
@property (nonatomic, assign) NSUInteger spsSize;
@property (nonatomic, assign) uint8_t pps;
@property (nonatomic, assign) NSUInteger ppsSize;
@property (nonatomic) CMVideoFormatDescriptionRef decodeDesc;
@end

@implementation CQVideoDecoder

- (void)dealloc {
    if (self.decodeSession) {
        VTDecompressionSessionInvalidate(self.decodeSession);
        CFRelease(self.decodeSession);
        self.decodeSession = NULL;
    }
}

- (instancetype)initWithConfig:(CQVideoConfig *)config {
    if (self = [super init]) {
        // 初始化videoConfig信息
        self.config = config;
        // 创建解码队列和回调队列
        self.decodeQueue = dispatch_queue_create("h264.decode.queue", DISPATCH_QUEUE_SERIAL);
        self.callbackQueue = dispatch_queue_create("h264.decode.callBack.queue", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

// 初始化解码器
- (BOOL)initDecoder {
    if (self.decodeSession) {
        return true;
    }
    
    const uint8_t * const parameterSetPointeers[2] = {_sps, _pps};
    const size_t parameterSetSize[2] = {_spsSize, _ppsSize};
    int naluHeaderLen = 4;
    
    /**
    根据sps 和pps 设置解码参数
     param kCFAllocatorDefault 分配器
     param 2 参数个数
     param parameterSetPointers 参数集指针
     param parameterSetSizes 参数集大小
     param naluHeaderLen nalu nalu start code 的长度 4
     param _decodeDesc 解码器描述
     return 状态
     */
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointeers, parameterSetSize, naluHeaderLen, &_decodeDesc);
    if (status != noErr) {
        NSLog(@"VideoFormatDescriptionCreateFromH264ParameterSets 失败 status = %d",(int)status);
        return false;
    }
    
    // 设置解码参数
    /**
     * kCVPixelBufferPixelFormatTypeKey:摄像头的输出数据格式
      kCVPixelBufferPixelFormatTypeKey，已测可用值为
         kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange，即420v
         kCVPixelFormatType_420YpCbCr8BiPlanarFullRange，即420f
         kCVPixelFormatType_32BGRA，iOS在内部进行YUV至BGRA格式转换
      YUV420一般用于标清视频，YUV422用于高清视频，这里的限制让人感到意外。但是，在相同条件下，YUV420计算耗时和传输压力比YUV422都小。
      
     * kCVPixelBufferWidthKey/kCVPixelBufferHeightKey: 视频源的分辨率 width*height
      * kCVPixelBufferOpenGLCompatibilityKey : 它允许在 OpenGL 的上下文中直接绘制解码后的图像，而不是从总线和 CPU 之间复制数据。这有时候被称为零拷贝通道，因为在绘制过程中没有解码的图像被拷贝.
     */
    NSDictionary *destinationPixBufferAttrs = @{
        (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8PlanarFullRange],
        (id)kCVPixelBufferWidthKey : [NSNumber numberWithInt:self.config.width],
        (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:self.config.height],
        (id)kCVPixelBufferOpenGLCompatibilityKey : [NSNumber numberWithBool:true]
    };
    
    // 解码回调设置
    VTDecompressionOutputCallbackRecord callbackRecord;
    callbackRecord.decompressionOutputCallback = videoDecompressionOutputCallback;
    callbackRecord.decompressionOutputRefCon = (__bridge void *)self;
    
    // 创建session
    /**
     @function    VTDecompressionSessionCreate
     @abstract    创建用于解压缩视频帧的会话。
     @discussion  解压后的帧将通过调用OutputCallback发出
     @param    allocator  内存的会话。通过使用默认的kCFAllocatorDefault的分配器。
     @param    videoFormatDescription 描述源视频帧
     @param    videoDecoderSpecification 指定必须使用的特定视频解码器.NULL
     @param    destinationImageBufferAttributes 描述源像素缓冲区的要求 NULL
     @param    outputCallback 使用已解压缩的帧调用的回调
     @param    decompressionSessionOut 指向一个变量以接收新的解压会话
     */
    status = VTDecompressionSessionCreate(kCFAllocatorDefault, _decodeDesc, NULL, (__bridge CFDictionaryRef)destinationPixBufferAttrs, &callbackRecord, &_decodeSession);
    if (status != noErr) {
        NSLog(@"video DecodeSession create failed status = %d", (int)status);
        return false;
    }
    
    // 设置解码会话属性
    status = VTSessionSetProperty(_decodeSession, kVTDecompressionPropertyKey_RealTime, kCFBooleanTrue);
    
    NSLog(@"DecompressionPropertyKey_RealTime status = %d", (int)status);
    
    return true;
}

// 解码回调函数
void videoDecompressionOutputCallback( void * CM_NULLABLE decompressionOutputRefCon,
                                        void * CM_NULLABLE sourceFrameRefCon,
                                        OSStatus status,
                                        VTDecodeInfoFlags infoFlags,
                                        CM_NULLABLE CVImageBufferRef imageBuffer,
                                        CMTime presentationTimeStamp,
                                        CMTime presentationDuration) {
    if (status != noErr) {
        NSLog(@"video hard decode callback error status = %d", (int)status);
        return;
    }
    
    // 解码后的数据 sourceFrameRefCon -> CVPixelBufferRef
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
    
    // 获取self
    CQVideoDecoder *decoder = (__bridge CQVideoDecoder *)decompressionOutputRefCon;
    
    // 调用回调队列
    dispatch_async(decoder.callbackQueue, ^{
        // 将解码后的数据给decoder代理
        [decoder.delegate videoDecodeCallback:imageBuffer];
        CVPixelBufferRelease(imageBuffer);
    });
}

- (void)decodeNaluData:(NSData *)frame {
    // 将解码放在异步队列中做
    dispatch_async(self.decodeQueue, ^{
        // 获取frame中的二进制数据
        uint8_t *nalu = (uint8_t *)frame.bytes;
        // 调用解码Nalu数据方法
        [self decodeNaluData:nalu size:(uint32_t)frame.length];
    });
}

// 解码函数 prevte
- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize {
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    CMBlockBufferFlags flag0 = 0;
    
    // 创建blockBuffer
    /**
     参数1: structureAllocator kCFAllocatorDefault
     参数2: memoryBlock  frame
     参数3: frame size
     参数4: blockAllocator: Pass NULL
     参数5: customBlockSource Pass NULL
     参数6: offsetToData  数据偏移
     参数7: dataLength 数据长度
     参数8: flags 功能和控制标志
     参数9: newBBufOut blockBuffer地址,不能为空
     */
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, frame, frameSize, kCFAllocatorNull, NULL, 0, frameSize, 0, &blockBuffer);
    if (status != kCMBlockBufferNoErr) {
        NSLog(@"video hard decode create blockBuffer error status = %d", status);
        return outputPixelBuffer;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    const size_t sampleSizeArray[] = {frameSize};
    
    // 创建sampleBuffer
    /**
     参数1: allocator 分配器,使用默认内存分配, kCFAllocatorDefault
     参数2: blockBuffer.需要编码的数据blockBuffer.不能为NULL
     参数3: formatDescription,视频输出格式
     参数4: numSamples.CMSampleBuffer 个数.
     参数5: numSampleTimingEntries 必须为0,1,numSamples
     参数6: sampleTimingArray.  数组.为空
     参数7: numSampleSizeEntries 默认为1
     参数8: sampleSizeArray
     参数9: sampleBuffer对象
     */
    status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, _decodeDesc, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
    if (status != noErr || !sampleBuffer) {
        NSLog(@"video hard decode create sampleBuffer error status = %d", (int)status);
        CFRelease(blockBuffer);
        return outputPixelBuffer;
    }
    
    // 解码
    // 使用低功耗模式
    VTDecodeFrameFlags flag1 = kVTDecodeFrame_1xRealTimePlayback;
    // 异步解码
    VTDecodeInfoFlags infoFlag = kVTDecodeInfo_Asynchronous;
    
    /**
     参数1: 解码session
     参数2: 源数据 包含一个或多个视频帧的CMsampleBuffer
     参数3: 解码标志
     参数4: 解码后数据outputPixelBuffer
     参数5: 同步/异步解码标识
     */
    status = VTDecompressionSessionDecodeFrame(_decodeSession, sampleBuffer, flag1, &outputPixelBuffer, &infoFlag);
    if (status == kVTInvalidSessionErr) {
        NSLog(@"Video hard decode InvalidSessionErr status = %d",(int)status);
    } else if (status == kVTVideoDecoderBadDataErr) {
        NSLog(@"video hard decode BadData status = %d", (int)status);
    } else if (status!= noErr) {
        NSLog(@"Video hard decode faild status = %d", (int)status);
    }
    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);
    
    return outputPixelBuffer;
}

- (void)decodeNaluData:(uint8_t *)frame size:(uint32_t)size {
    // 数据类型：frame的前4个字节是Nalu数据的开始码，也就是 00 00 00 01
    // 第五个字节是表示数据类型，转为10进制后 7是sps 8是pps 5是IDR I帧的信息
    int type = (frame[4] & 0x1F);
    
    // 将NALU的开始码转为4字节大端的Nalu的长度信息
    uint32_t naluSize = size - 4;
    uint8_t *pNaluSize = (uint8_t *)(&naluSize);
    CVPixelBufferRef pixelBuffer = NULL;
    //TODO:这里忘记为什么这样写了(大端转端？)
    frame[0] = *(pNaluSize + 3);
    frame[1] = *(pNaluSize + 2);
    frame[2] = *(pNaluSize + 1);
    frame[3] = *(pNaluSize);
    
    // 第一次解析时初始化initDecoder
    // 关键帧和其他帧数据调用self decpde:frame withSize:size];
    
    switch (type) {
        case 0x05:
            // 关键帧
            if ([self initDecoder]) {
                pixelBuffer = [self decode:frame withSize:size];
            }
            break;
        case 0x06:
            // 增强信息
            break;
        case 0x07:
            // sps
            self.spsSize = naluSize;
            _sps = malloc(_spsSize);
            memcpy(_sps, &frame[4], _spsSize);
            break;
        case 0x08:
            _ppsSize = naluSize;
            _pps = malloc(_ppsSize);
            memcpy(_pps, &frame[4], _ppsSize);
            break;
        default:
            // 其他
            if ([self initDecoder]) {
                pixelBuffer = [self decode:frame withSize:size];
            }
            break;
    }
}
@end
