//
//  CQDownloadOperation.m
//  CQProject
//
//  Created by CharType on 2020/8/2.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQDownloadOperation.h"

@interface CQDownloadOperation()
@property (nonatomic, strong) NSURL *url;
// 进度回调
@property (nonatomic, copy) void (^downloadProgressBlock)(NSProgress *downloadProgress);
// 存储路径回调
@property (nonatomic, copy) NSURL * (^destination)(NSURL *targetPath, NSURLResponse *response);
// 成功和失败回调
@property (nonatomic, copy) void (^completionHandler)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error);

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@end

@implementation CQDownloadOperation

- (void)dealloc {
    [self.task cancel];
}

- (instancetype)initWithUrl:(NSURL *)url
                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
          completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler {
    if (self = [super init]) {
        self.url = url;
        self.downloadProgressBlock = downloadProgressBlock;
        self.destination = destination;
        self.completionHandler = completionHandler;
    }
    return self;
}

- (void)main {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.allowsCellularAccess = YES;
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
//    AFHTTPResponseSerializer *responseSerializer = [[AFHTTPResponseSerializer alloc] init];
//    self.sessionManager.responseSerializer = responseSerializer;
//      AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    self.sessionManager.securityPolicy = securityPolicy;
//    self.sessionManager.securityPolicy.validatesDomainName = NO;
//    self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    self.task = [self.sessionManager downloadTaskWithRequest:request progress:self.downloadProgressBlock destination:self.destination completionHandler:self.completionHandler];
    [self.task resume];
}
@end
