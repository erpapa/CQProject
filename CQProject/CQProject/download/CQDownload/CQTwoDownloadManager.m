//
//  CQTwoDownloadManager.m
//  CQProject
//
//  Created by CharType on 2020/8/3.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQTwoDownloadManager.h"
#import "NSString+CQDownload.h"

// 存放所有文件的大小
static NSMutableDictionary *_totleFileSize;
// 存放所有文件大小的路径
static NSString *_totalFileSizesFilePath;

static NSString * const CQDownloadRootDir = @"CQDownload";

static NSString * const CQDowndloadManagerDefaultIdentifier = @"www.ashaj.com";

@interface CQDownloadInfo()
{
    CQDownloadState _state;
    NSInteger _totalBytesWritten;
}
// 下载状态
@property (nonatomic, assign, readwrite) CQDownloadState state;
// 当前回调写入数量
@property (nonatomic, assign, readwrite) NSInteger bytesWritten;
// 已经下载写入数量
@property (nonatomic, assign, readwrite) NSInteger totalBytesWritten;
// 总共需要写入数量
@property (nonatomic, assign, readwrite) NSInteger totalBytesExpectedToWrite;
// 文件名
@property (nonatomic, strong, readwrite) NSString *fileName;
// 文件存储路径
@property (nonatomic, strong, readwrite) NSString *filePath;
// 文件对应的url
@property (nonatomic, strong, readwrite) NSString *url;
// 文件下载对应的错误信息
@property (nonatomic, strong, readwrite) NSError *error;

// 下载进度回调
@property (nonatomic, copy) CQDownloadProgressChanageBlock progressBlock;
// 保存状态发生改变时候的回调
@property (nonatomic, copy) CQDownloadStateChangeBlock stateChangeBlock;
// 下载的task
@property (nonatomic, strong) NSURLSessionDataTask *task;
// 文件流
@property (nonatomic, strong) NSOutputStream *stream;
@end

@implementation CQDownloadInfo
#pragma mark - 代理方法回调
- (void)didReceiveResponse:(NSHTTPURLResponse *)response {
    // 1. 获取文件的总长度
    if (!self.totalBytesExpectedToWrite) {
        // ? 为什么要加上bytesWritten 呢
        self.totalBytesExpectedToWrite = [response.allHeaderFields[@"Content-Length"] integerValue] + self.bytesWritten;
        // 2. 存储文件的总长度
        _totleFileSize[self.url] = @(self.totalBytesExpectedToWrite);
    }
    // 3. 打开流
    [self.stream open];
    // 4. 清空错误
    self.error = nil;
}

- (void)didReceiveData:(NSData *)data {
    NSInteger length = [self.stream write:data.bytes maxLength:data.length];
    if (length == -1) {
        self.error = self.stream.streamError;
        [self.task cancel];
    } else {
        self.bytesWritten = data.length;
        //？ 这里没有更新当前已经写入的数量
        [self notifyProgressChange];
    }
}
// 下载完成或者出错的回调
- (void)didCompleteWithError:(NSError *)error {
    // 1.关闭流
    [self.stream close];
    self.bytesWritten = 0;
    self.task = nil;
    self.stream = nil;
    self.error = error ? error : self.error;
    
    if (self.state == CQDownloadStateCompleted || error) {
        self.state = error ? CQDownloadStateNone : CQDownloadStateCompleted;
    }
}

#pragma mark -状态控制
- (void)setState:(CQDownloadState)state {
    CQDownloadState oldState = self.state;
    if (oldState == state) return;
    _state = state;
    [self notifyStateChange];
}

// 取消一个任务
- (void)cancel {
    // 如果是这两种状态不需要取消
    if (self.state == CQDownloadStateNone || self.state == CQDownloadStateCompleted) return;
    [self.task cancel];
    self.state = CQDownloadStateNone;
}

// 恢复一个任务
- (void)resume {
    // 这两种状态不需要恢复下载
    if (self.state == CQDownloadStateResume || self.state == CQDownloadStateWillResume) return;
    [self.task resume];
    self.state = CQDownloadStateResume;
}

- (void)willResume {
    // 如果已经是这三种状态的话不需要恢复下载
    if (self.state == CQDownloadStateWillResume || self.state == CQDownloadStateResume || self.state == CQDownloadStateCompleted) {
        return;
    }
    self.state = CQDownloadStateWillResume;
}

// 暂停任务
- (void)suspend {
    // 如果已经下载完毕或者已经暂停，不需要暂停
    if(self.state == CQDownloadStateCompleted || self.state == CQDownloadStateSuspend) return;
    if (self.state == CQDownloadStateResume) {
        // 如果是正在下载，就暂停
        [self.task suspend];
        self.state = CQDownloadStateSuspend;
    } else {
        // 如果是等待下载就设置为None
        self.state = CQDownloadStateNone;
    }
}

#pragma mark - 初始化任务
- (void)setupTask:(NSURLSession *)session {
    if (self.task) {
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    // 设置断点续传参数
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.totalBytesWritten];
    [request setValue:range forHTTPHeaderField:@"Range"];
    self.task = [session dataTaskWithRequest:request];
    self.task.taskDescription = self.url;
}
// 下载进度改变通知调用者
- (void)notifyProgressChange {
    if (self.progressBlock) {
        self.progressBlock(self.bytesWritten, self.totalBytesWritten, self.totalBytesExpectedToWrite);
    }
}
// 下载状态发生改变通知调用者
- (void)notifyStateChange {
    if(self.stateChangeBlock) {
        self.stateChangeBlock(self.state, self.filePath, self.error);
    }
}

#pragma mark getter

- (NSString *)filePath {
    if (!_filePath) {
        _filePath = [[NSString stringWithFormat:@"%@/%@",CQDownloadRootDir,self.fileName] cq_prependCaches];
    }
    if (_filePath && ![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        // 如果没有创建文件夹，先创建一个文件夹
        NSString *dir = [_filePath stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _filePath;
}

- (NSString *)fileName {
    if (!_fileName) {
        NSString *pathExtension = self.url.pathExtension;
        if (pathExtension.length) {
            _fileName = [NSString stringWithFormat:@"%@.%@",self.url.cq_MD5,pathExtension];
        } else {
            _fileName = self.url.cq_MD5;
        }
    }
    return _fileName;
}

- (NSOutputStream *)stream {
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    }
    return _stream;
}

- (NSInteger) totalBytesWritten {
    return self.filePath.cq_fileSize;
}

- (NSInteger)totalBytesExpectedToWrite {
    if (!_totalBytesExpectedToWrite) {
        _totalBytesExpectedToWrite = [_totleFileSize[self.url] integerValue];
    }
    return _totalBytesExpectedToWrite;
}

- (CQDownloadState)state {
    if (self.totalBytesWritten && self.totalBytesWritten == self.totalBytesExpectedToWrite) {
        return CQDownloadStateCompleted;
    }
    if (self.task.error) return CQDownloadStateNone;
    return _state;
}

@end

@interface CQTwoDownloadManager()<NSURLSessionDataDelegate>
// session
@property (nonatomic, strong) NSURLSession *session;
// 存放所有文件的下载信息
@property (nonatomic, strong) NSMutableArray *downloadInfoArray;
// 是否正在批量处理
@property (nonatomic, assign,getter=isBatchinng) BOOL batching;
// 队列
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation CQTwoDownloadManager
// 存放所有的manager
static NSMutableDictionary *_managers;
// 递归锁
static NSRecursiveLock *_lock;
+ (void)initialize {
    
    _totalFileSizesFilePath = [NSString stringWithFormat:@"%@/%@",CQDownloadRootDir, [@"cqDownloadFileSizes.plist".cq_MD5 cq_prependCaches]];
    _totleFileSize = [NSMutableDictionary dictionaryWithContentsOfFile:_totalFileSizesFilePath];
    if (_totleFileSize == nil) {
        _totleFileSize = [NSMutableDictionary dictionary];
    }
    _managers = [NSMutableDictionary dictionary];
    _lock = [[NSRecursiveLock alloc] init];
}

+ (instancetype)defaultManager {
    return [self managerWithIdentifier:CQDowndloadManagerDefaultIdentifier];
}

+ (instancetype)manager {
    return [[self alloc] init];
}

+ (instancetype)managerWithIdentifier:(NSString *)identifier {
    if (![identifier isNotBlank]) {
        return [self manager];
    }
    CQTwoDownloadManager *manager = _managers[identifier];
    if (!manager) {
        manager = [self manager];
        _managers [identifier] = manager;
    }
    return manager;
}

#pragma mark - 文件操作
// 让第一个等待的文件开始下载
- (void)resumeFirstWillResume {
    if (self.isBatchinng) return;
    // 从列表中找到第一个等待下载的去下载
    CQDownloadInfo *willInfo = [self.downloadInfoArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d",CQDownloadStateWillResume]].firstObject;
    [self resumeUrl:willInfo.url];
}

- (void)cancelAll {
    [self.downloadInfoArray enumerateObjectsUsingBlock:^(CQDownloadInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelUrl:info.url];
    }];
}

+ (void)cancelAll {
    [_managers.allValues makeObjectsPerformSelector:@selector(cancelAll)];
}

- (void)suspendAll {
    self.batching = YES;
    [self.downloadInfoArray enumerateObjectsUsingBlock:^(CQDownloadInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspendUrl:info.url];
    }];
    self.batching = NO;
}

+ (void)suspendAll {
    [_managers.allValues makeObjectsPerformSelector:@selector(suspendAll)];
}

- (void)resumeAll {
    //？ 为什么不标记为批量处理了，标记批量处理是为了只有一个暂停的时候自动开启下一个，批量处理的过程中不需要
    [self.downloadInfoArray enumerateObjectsUsingBlock:^(CQDownloadInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspendUrl:info.url];
    }];
}

+ (void)resumeAll {
    [_managers.allValues makeObjectsPerformSelector:@selector(resumeAll)];
}

- (void)cancelUrl:(NSString *)url {
    if (url == nil) return;
    [[self downloadInfoUrl:url] cancel];
    // 这里真的不需要取出第一个等待下载的吗？
}

- (void)suspendUrl:(NSString *)url {
    if (url == nil) return;
    [[self downloadInfoUrl:url] suspend];
    // 取出第一个等待下载的去开始下载
    [self resumeFirstWillResume];
}

- (void)resumeUrl:(NSString *)url {
    if (url == nil) return;
    // 获取下载信息
    CQDownloadInfo *info = [self downloadInfoUrl:url];
    // 获取正在下载的任务
    NSArray *downloadingDownloadInfoArray = [self.downloadInfoArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d",CQDownloadStateResume]];
    if (self.maxDownloadCount && downloadingDownloadInfoArray.count == self.maxDownloadCount) {
        [info willResume];
    } else {
        [info resume];
    }
}

#pragma mark - - <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 获取下载信息
    CQDownloadInfo *info = [self downloadInfoUrl:dataTask.taskDescription];
    // 处理响应
    [info didReceiveResponse:response];
    // 继续下载
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data {
    // 获取下载信息
    CQDownloadInfo *info = [self downloadInfoUrl:dataTask.taskDescription];
    // 处理数据
    [info didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    // 获取信息
    CQDownloadInfo *info = [self downloadInfoUrl:task.taskDescription];
    // 处理结束
    [info didCompleteWithError:error];
    // 恢复等待的下载
    [self resumeFirstWillResume];
}

#pragma mark - 公用的方法
- (CQDownloadInfo *)downloadUrl:(NSString *)url {
    return [self downloadUrl:url state:nil];
}

- (CQDownloadInfo *)downloadInfoUrl:(NSString *)url {
    if (url == nil) return nil;
    //? downloadInfoArray 是不是可以改成哈希表存储
   CQDownloadInfo *info = [self.downloadInfoArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"url == %@",url]].firstObject;
    if (info == nil) {
        info = [[CQDownloadInfo alloc] init];
        info.url = url;
        [self.downloadInfoArray addObject:info];
    }
    return info;
}

- (CQDownloadInfo *)downloadUrl:(NSString *)url state:(CQDownloadStateChangeBlock)block {
    return [self downloadUrl:url toDestinationPath:nil progress:nil state:block];
}

- (CQDownloadInfo *)downloadUrl:(NSString *)url progress:(CQDownloadProgressChanageBlock)progressBlock state:(CQDownloadStateChangeBlock)block {
    return [self downloadUrl:url toDestinationPath:nil progress:progressBlock state:block];
}

- (CQDownloadInfo *)downloadUrl:(NSString *)url toDestinationPath:(NSString *)toDestinationPath progress:(CQDownloadProgressChanageBlock)progressBlock state:(CQDownloadStateChangeBlock)block {
    if (url == nil) return nil;
    // 获取下载信息
    CQDownloadInfo *info = [self downloadInfoUrl:url];
    // 设置回调block
    info.progressBlock = progressBlock;
    info.stateChangeBlock = block;
    // 设置路径信息，如果有传
    if ([toDestinationPath isNotBlank]) {
        info.filePath = toDestinationPath;
        info.fileName = [toDestinationPath lastPathComponent];
    }
    
    if (info.state == CQDownloadStateCompleted) {
        // 如果已经下载完毕，通知外层一次
        [info notifyStateChange];
        return info;
    } else if(info.state == CQDownloadStateResume) {
        // 如果正在下载，通知外层一次
        return info;
    }
    // 创建任务
    [info setupTask:self.session];
    // 开始任务
    [self resumeUrl:url];
    return info;
}

#pragma mark - 懒加载
- (NSURLSession *)session {
    if (!_session) {
        // 默认配置
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // session
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.queue];
    }
    return _session;;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

- (NSMutableArray *)downloadInfoArray {
    if (!_downloadInfoArray) {
        _downloadInfoArray = [NSMutableArray array];
    }
    return _downloadInfoArray;
}

@end
