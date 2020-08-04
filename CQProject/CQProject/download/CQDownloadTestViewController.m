//
//  CQDownloadTestViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/2.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQDownloadTestViewController.h"
#import "CQDownloadManager.h"
#import "CQDownloadOperation.h"
#import "MJDownloadManager.h"
#import "CQTwoDownloadManager.h"

@interface CQDownloadTestViewController ()
@property (nonatomic, strong) CQDownloadManager *downManager;
@property (nonatomic, strong) MJDownloadManager *mjDownloadManager;
@property (nonatomic, strong) CQTwoDownloadManager *cqdownloadManager;
@property (nonatomic, strong) CQDownloadInfo *info2;
@property (nonatomic, strong) CQDownloadInfo *info3;
@property (nonatomic, strong) CQDownloadInfo *info4;
@property (nonatomic, strong) CQDownloadInfo *info5;
@end

@implementation CQDownloadTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mjDownloadManager = [MJDownloadManager defaultManager];
    self.cqdownloadManager = [CQTwoDownloadManager defaultManager];
    self.title = @"下载Demo测试";
    
    NSString *url2= @"http://vod.lycheer.net/e22cd48bvodtransgzp1253442168/35cde54f5285890791443358630/v.f30.mp4";
//    NSString *url3= @"http://vod.lycheer.net/e22cd48bvodtransgzp1253442168/e4c75d185285890795231957572/v.f30.mp4";
//    NSString *url4= @"http://vod.lycheer.net/e22cd48bvodtransgzp1253442168/7ca811775285890795471886042/v.f30.mp4";
//    NSString *url5= @"http://vod.lycheer.net/e22cd48bvodtransgzp1253442168/754fce705285890795471539301/v.f30.mp4";
    // toDestinationPath:@"/Users/chengqian/Desktop/下载/1.mp4"
    self.info2 = [self.cqdownloadManager downloadUrl:url2  toDestinationPath:@"/Users/chengqian/Desktop/下载/1.mp4" progress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        NSLog(@"进度回调 本次写入长度%ld,已经写入多少%ld,总共写入多少%ld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    } state:^(CQDownloadState state, NSString *filePath, NSError *error) {
        NSLog(@"状态改变回调 state %ld,文件路径：%@ 错误信息%@",state,filePath,error);
    }];
    
}

- (CQDownloadManager *)downManager {
    if (!_downManager) {
        _downManager = [CQDownloadManager defaultManager];
    }
    return _downManager;
}

@end
