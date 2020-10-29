//
//  CQAudioEncoder.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class CQAudioConfig;

@protocol CQAudioEncoderDelegate <NSObject>
- (void)audioEncoderCallBack:(NSData *)aacData;
@end

@interface CQAudioEncoder : NSObject
@property (nonatomic, strong) CQAudioConfig *config;
@property (nonatomic, weak) id<CQAudioEncoderDelegate> delegate;
- (instancetype)initWithConfig:(CQAudioConfig *)config;
- (void)encodeAudioSamepleBuffer:(CMSampleBufferRef)sampleBuffer;
// 将sampleBuffer数据提取出PCM数据，返回给ViewController,可以直接播放pcm数据
- (NSData *)convertAudioSamepleBufferToPcmData:(CMSampleBufferRef)sampleBuffer;
@end

