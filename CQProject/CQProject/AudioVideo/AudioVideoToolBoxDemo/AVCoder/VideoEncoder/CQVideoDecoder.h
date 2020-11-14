//
//  CQVideoDecoder.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class CQVideoConfig;

@protocol CQVideoDecoderDelegate <NSObject>
// 解码h264后回调
- (void)videoDecodeCallback:(CVPixelBufferRef)imageBuffer;

@end

@interface CQVideoDecoder : NSObject
@property (nonatomic, strong) CQVideoConfig *config;
@property (nonatomic, weak) id<CQVideoDecoderDelegate> delegate;
// 初始化解码器
- (instancetype)initWithConfig:(CQVideoConfig *)config;
// 解码h264数据
- (void)decodeNaluData:(NSData *)frame;
@end

