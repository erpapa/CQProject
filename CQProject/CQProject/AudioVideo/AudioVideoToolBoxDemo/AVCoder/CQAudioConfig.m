//
//  CQAudioConfig.m
//  CQProject
//
//  Created by CharType on 2020/10/28.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAudioConfig.h"

@implementation CQAudioConfig
+ (instancetype)defaultConfig {
    return [[CQAudioConfig alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.birtrate = 96000;
        self.channelCount = 1;
        self.sampleSize = 16;
        self.sampleRete = 44100;
    }
    return self;
}
@end

@implementation CQVideoConfig
+ (instancetype)defaultConfig {
    return [[CQVideoConfig alloc] init];
}
- (instancetype)init {
    if (self = [super init]) {
        self.width = 480;
        self.height = 640;
        self.bitrate = 640 * 1000;
        self.fps = 25;
    }
    return self;
}
@end
