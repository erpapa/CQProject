//
//  CQAudioPCMPlayer.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CQAudioConfig;
@interface CQAudioPCMPlayer : NSObject
- (instancetype)initWithConfig:(CQAudioConfig *)config;
// 播放pcm
- (void)playPCMData:(NSData *)data;
// 设置音量增量 0到1
- (void)setupVoice:(Float32)gain;
// 销毁
- (void)dispose;
@end
