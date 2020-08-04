//
//  CQTwoDownloadManager.h
//  CQProject
//
//  Created by CharType on 2020/8/3.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CQDownloadState) {
    CQDownloadStateNone = 0, // 默认状态
    CQDownloadStateWillResume, // 即将开始下载
    CQDownloadStateResume, // 下载中
    CQDownloadStateSuspend,// 暂停中
    CQDownloadStateCompleted, // 下载完毕
};

// 进度更新回调
// bytesWritten 当前回调写入的数量
// totalBytesWritten 已经写入的数量
// totalBytesExpectedToWrite 所有的需要写入的数量
typedef void (^CQDownloadProgressChanageBlock) (NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

// 状态发生改变时候的回调
// state： 当前状态
// filepath： 文件存储的路径
// error：如果出错存储error信息
typedef void (^CQDownloadStateChangeBlock)(CQDownloadState state,NSString *filePath,NSError *error);


@interface CQDownloadInfo : NSObject
// 下载状态
@property (nonatomic, assign, readonly) CQDownloadState state;
// 当前回调写入数量
@property (nonatomic, assign, readonly) NSInteger bytesWritten;
// 已经下载写入数量
@property (nonatomic, assign, readonly) NSInteger totalBytesWritten;
// 总共需要写入数量
@property (nonatomic, assign, readonly) NSInteger totalBytesExpectedToWrite;
// 文件名
@property (nonatomic, strong, readonly) NSString *fileName;
// 文件存储路径
@property (nonatomic, strong, readonly) NSString *filePath;
// 文件对应的url
@property (nonatomic, strong, readonly) NSString *url;
// 文件下载对应的错误信息
@property (nonatomic, strong, readonly) NSError *error;

@end

@interface CQTwoDownloadManager : NSObject
// 队列
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
// 下载的最大线程数
@property (nonatomic, assign) NSInteger maxDownloadCount;

+ (instancetype)defaultManager;
+ (instancetype)manager;
+ (instancetype)managerWithIdentifier:(NSString *)identifier;

// 当前Manager对应的文件取消下载，需要重新调用download方法才能重新去下载
- (void)cancelAll;
// 全部Manager对应的文件取消下载，需要重新调用download方法才能重新去下载
+ (void)cancelAll;
// 单个文件取消下载 需要调download方法重新下载
- (void)cancelUrl:(NSString *)url;

// 全部Manager中的文件全部暂停下载 需要重新调用download方法才能重新去下载
+ (void)suspendAll;
// 当前manager中的文件全部取消下载 需要重新调用download方法才能重新去下载
- (void)suspendAll;
// 单个文件暂停下载
- (void)suspendUrl:(NSString *)url;

// 全部开始或者继续所有文件的下载
+ (void)resumeAll;
- (void)resumeAll;
// 开始或者继续单个文件下载
- (void)resumeUrl:(NSString *)url;

// 根据url获取到下载信息
- (CQDownloadInfo *)downloadInfoUrl:(NSString *)url;

// 根据url下载一个文件
- (CQDownloadInfo *)downloadUrl:(NSString *)url;


/// 根据url下载一个文件
/// @param url 下载链接
/// @param block 下载状态发生改变时候的回调
- (CQDownloadInfo *)downloadUrl:(NSString *)url state:(CQDownloadStateChangeBlock)block;


/// 根据url下载一个文件
/// @param url 下载链接
/// @param progressBlock  进度发生变化时候的回调
/// @param block 下载状态发生改变时候的回调
- (CQDownloadInfo *)downloadUrl:(NSString *)url progress:(CQDownloadProgressChanageBlock)progressBlock state:(CQDownloadStateChangeBlock)block;

/// 根据url下载一个文件
/// @param url 下载链接
/// @param toDestinationPath 文件存放地址
/// @param progressBlock 进度回调block
/// @param block 状态发生改变的回调
- (CQDownloadInfo *)downloadUrl:(NSString *)url toDestinationPath:(NSString *)toDestinationPath progress:(CQDownloadProgressChanageBlock)progressBlock state:(CQDownloadStateChangeBlock)block;






@end

//NS_ASSUME_NONNULL_END
