//
//  CQDownloadOperation.h
//  CQProject
//
//  Created by CharType on 2020/8/2.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQDownloadOperation : NSOperation
- (instancetype)initWithUrl:(NSURL *)url
         progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
      destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
          completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
