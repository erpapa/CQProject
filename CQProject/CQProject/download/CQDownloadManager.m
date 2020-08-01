//
//  CQDownloadManager.m
//  CQProject
//
//  Created by CharType on 2020/7/27.
//  Copyright © 2020 CharType. All rights reserved.
//  下载管理类，是一个单例

#import "CQDownloadManager.h"
#import "CQDownloadConfig.h"

@interface CQDownloadManager()
@property (nonatomic, strong) CQDownloadConfig *downloadConfig;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation CQDownloadManager

+ (CQDownloadManager *)defaultManager {
    return [self defaultManagerwithConfig:nil];
}
+ (CQDownloadManager *)defaultManagerwithConfig:(CQDownloadConfig *)config {
    static CQDownloadManager *manager = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        manager = [[CQDownloadManager alloc] initWithConfig:config];
    });
    return manager;
}

- (instancetype) initWithConfig:(CQDownloadConfig *)config {
    if (self = [super init]) {
        self.downloadConfig = config;
    }
    return self;
}

- (CQDownloadConfig *)downloadConfig {
    if (!_downloadConfig) {
        _downloadConfig = [[CQDownloadConfig alloc] init];
        _downloadConfig.maxFileCount = 20;
        _downloadConfig.maxThreadCount = 10;
        _downloadConfig.diskcacheSize = 10 * 1024 * 1024;
    }
    return _downloadConfig;
}
@end
