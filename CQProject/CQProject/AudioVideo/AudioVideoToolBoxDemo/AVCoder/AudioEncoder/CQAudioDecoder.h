//
//  CQAudioiDecoder.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class CQAudioConfig;

@protocol CQAudioDecoderDelegate <NSObject>
- (void)audioDecodeCallback:(NSData *)pcmData;
@end

@interface CQAudioDecoder : NSObject
@property (nonatomic, strong) CQAudioConfig *config;
@property (nonatomic, weak) id<CQAudioDecoderDelegate> delegate;
- (instancetype)initWithConfig:(CQAudioConfig *)config;
- (void)decodeAudioAACData:(NSData *)aacData;
@end

