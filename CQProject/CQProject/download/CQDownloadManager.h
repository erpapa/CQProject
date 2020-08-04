//
//  CQDownloadManager.h
//  CQProject
//
//  Created by CharType on 2020/7/27.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CQDownloadConfig;
@class CQDownloadOperation;
@interface CQDownloadManager : NSObject
+ (CQDownloadManager *)defaultManager;
+ (CQDownloadManager *)defaultManagerwithConfig:(CQDownloadConfig *)config;

- (CQDownloadOperation *)downloadWithUrl:(NSString *)url
                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

- (void)addOperationToQueue:(NSOperation *)operation;
@end

NS_ASSUME_NONNULL_END
