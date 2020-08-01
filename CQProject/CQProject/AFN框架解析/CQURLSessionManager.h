//
//  CQURLSessionManager.h
//  CQProject
//
//  Created by CharType on 2020/7/26.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN;

@interface CQURLSessionManager : NSObject<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate,NSSecureCoding,NSCopying>

@property (nonatomic, strong) NSURLSession * _Nullable session;

@property (nonatomic, strong, readonly) NSOperationQueue *opeerationQueue;
// 数据解析相关的
@property (nonatomic, strong) id<AFURLResponseSerialization> responseSerializer;

@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

@property (nonatomic, strong, readonly) NSArray<NSURLSessionTask *> *tasks;

@property (nonatomic, strong, readonly) NSArray<NSURLSessionDataTask *> *dataTasks;

@property (nonatomic, strong, readonly) NSArray<NSURLSessionUploadTask *> *uploadTasks;

@property (nonatomic, strong, readonly) NSArray<NSURLSessionDownloadTask *> *downloadTasks;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;

@property (nonatomic, assign) BOOL attemptsToRecreateUploadTasksforBackgroundSessions;

- (instancetype _Nullable ) initWithSessionConfiguration:(NSURLSessionConfiguration *_Nonnull)configuration;

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks;

- (NSURLSessionDataTask *_Nullable)dataTaskWithRequest:(NSURLRequest *)request
                                     completionHandler:(nonnull void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionDataTask *_Nullable)dataTaskWithRequest:(NSURLRequest *)request
                                        uploadProgress:(nullable void (^)(NSProgress * _Nonnull))uploadProgressBlock
                                      downloadProgress:(nullable void (^)(NSProgress * _Nonnull))downloadProgressBlock
                                     completionHandler:(nullable void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(nonnull NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                        completionHandler:(nullable void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError *
                                                                             _Nullable))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgressBlock
                                          destination:(nullable NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                                    completionHandler:(nullable void (^)(NSURLResponse * _Nonnull, NSURL * _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgressBlock
                                             destination:(nullable NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                                       completionHandler:(nullable void (^)(NSURLResponse * _Nonnull, NSURL * _Nullable, NSError * _Nullable))completionHandler;

- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

- (void)setSessionDidBecomeInvalidBlock:(void (^)(NSURLSession *session,NSError *error))block;

NS_ASSUME_NONNULL_END;
@end
