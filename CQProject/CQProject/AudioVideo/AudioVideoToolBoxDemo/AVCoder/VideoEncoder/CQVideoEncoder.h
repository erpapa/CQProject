//
//  CQVideoEncoder.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class CQVideoConfig;

@protocol CQVideoEncoderDelegate <NSObject>
// h264编码完成回调
- (void)videoEncodeCallback:(NSData *)h264Data;
// sps和pps 数据编码回调
- (void)videoEncodeCallBackSps:(NSData *)sps pps:(NSData *)pps;
@end


@interface CQVideoEncoder : NSObject
@property (nonatomic, strong) CQVideoConfig *config;
@property (nonatomic, weak) id<CQVideoEncoderDelegate> delegate;
- (instancetype)initWithConfig:(CQVideoConfig *)config;
// 编码
- (void)encodeVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
