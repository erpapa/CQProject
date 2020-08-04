//
//  CQDownloadManager.m
//  CQProject
//
//  Created by CharType on 2020/7/27.
//  Copyright © 2020 CharType. All rights reserved.
//  下载管理类，是一个单例

#import "CQDownloadManager.h"
#import "CQDownloadConfig.h"
#import "CQDownloadOperation.h"

@interface CQDownloadManager()
@property (nonatomic, strong) CQDownloadConfig *downloadConfig;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *stopOperation;
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


- (CQDownloadOperation *)downloadWithUrl:(NSString *)url
         progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
      destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler {
    if (![url isNotBlank]) {
        return nil;
    }
    NSURL *URL = [NSURL URLWithString:url];
    CQDownloadOperation *operation = [[CQDownloadOperation alloc] initWithUrl:URL progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    
    return operation;
}

- (void)addOperationToQueue:(NSOperation *)operation {
    if (operation != nil && [operation isKindOfClass:[NSOperation class]]) {
        [self.operationQueue addOperation:operation];
    }
    
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

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        if (self.downloadConfig) {
            _operationQueue.maxConcurrentOperationCount = self.downloadConfig.maxThreadCount;
        } else {
            _operationQueue.maxConcurrentOperationCount = 10;
        }
    }
    return _operationQueue;
}

@end
