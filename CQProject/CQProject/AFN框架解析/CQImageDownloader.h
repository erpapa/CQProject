//
//  CQImageDownloader.h
//  CQProject
//
//  Created by CharType on 2020/7/22.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CQImageCache <NSObject>

@end

@protocol CQImageRequestCache <CQImageCache>


@end

typedef NS_ENUM(NSInteger,CQImageDownloaderPrioritization) {
    CQImageDownloaderReceiptFIFO,// 先进先出
    CQImageDownloaderReceiptLIFO// 后进先出
};

// 对下载对象的封装
@interface CQImageDownloaderReceipt : NSObject
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSUUID *receiptID;
@end

@implementation CQImageDownloaderReceipt
@end

@interface CQImageDownloader : NSObject
@property (nonatomic, strong) id<CQImageRequestCache> imageCache;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) CQImageDownloaderPrioritization downloaderPrioritization;
+ (instancetype)defaultInstance;
+ (NSURLCache *)defaultURLCache;
- (instancetype)init;
- (instancetype)initWithSessionManager:(AFHTTPSessionManager *)sessionManager
              downloaderPrioritization:(CQImageDownloaderPrioritization)downloaderPrioritization
                maximumActiveDownloads:(NSInteger)maximumActiveDownloads
                            imageCache:(id<CQImageRequestCache>)imageCahce;

- (CQImageDownloaderReceipt *)downloadImageForUrlRequest:(NSURLRequest *)request
                                                 success:(nullable void (^)(NSURLRequest *request,NSHTTPURLResponse * _Nullable response,UIImage * _Nullable responseObject))success
                                                 failure:(nullable void (^)(NSURLRequest * _Nonnull request,NSHTTPURLResponse * _Nullable response,NSError * _Nullable error))failure;

- (CQImageDownloaderReceipt *_Nullable)downloadImageForUrlRequest:(NSURLRequest *_Nullable)request
                                               receiptId:(NSUUID *_Nullable)receoptId
                                                          success:(nullable void (^)(NSURLRequest * _Nullable request,NSHTTPURLResponse * _Nullable response,UIImage * _Nonnull responseObject))success
                                                 failure:(nullable void (^)(NSURLRequest * _Nonnull request,NSHTTPURLResponse * _Nullable response,NSError * _Nullable error))failure;


- (void)cancelTaskForImageDownloadeReceipt:(CQImageDownloaderReceipt *_Nullable)downloaderReceipt;
@end

