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

@interface CQDownloadManager : NSObject
+ (CQDownloadManager *)defaultManager;
+ (CQDownloadManager *)defaultManagerwithConfig:(CQDownloadConfig *)config;

@end

NS_ASSUME_NONNULL_END
