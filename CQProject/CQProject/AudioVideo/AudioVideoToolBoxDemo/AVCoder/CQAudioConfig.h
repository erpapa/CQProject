//
//  CQAudioConfig.h
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

// 音频配置
@interface CQAudioConfig : NSObject
// 码率
@property (nonatomic, assign) NSInteger birtrate;
// 声道
@property (nonatomic, assign) NSInteger channelCount;
// 采样率
@property (nonatomic, assign) NSInteger sampleRete;
// 采样点量化
@property (nonatomic, assign) NSInteger sampleSize;
+ (instancetype)defaultConfig;
@end

@interface CQVideoConfig : NSObject
// 可选,系统支持的分辨率，
@property (nonatomic, assign) NSInteger width;
// 视频高
@property (nonatomic, assign) NSInteger height;
// 码率上限
@property (nonatomic, assign) NSInteger bitrate;
// 期望帧率
@property (nonatomic, assign) NSInteger fps;
+ (instancetype)defaultConfig;
@end
