//
//  CQDownloadConfig.h
//  CQProject
//
//  Created by CharType on 2020/7/27.
//  Copyright © 2020 CharType. All rights reserved.
//  下载配置信息

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQDownloadConfig : NSObject
// 最多多少个线程一起下载
@property (nonatomic, assign) NSInteger maxThreadCount;
// 最多占用多少的磁盘空间
@property (nonatomic, assign) NSInteger diskcacheSize;
// 最多保存多少个文件（文件数量和磁盘空间冲突的时候优先文件数量）
@property (nonatomic, assign) NSInteger maxFileCount;
@end

NS_ASSUME_NONNULL_END
