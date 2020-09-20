//
//  NSString+CQDownload.h
//  CQProject
//
//  Created by CharType on 2020/8/3.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CQDownload)
// 在当前字符前面拼接Cache目录
- (NSString *)cq_prependCaches;
// 生成md5值
- (NSString *)cq_MD5;
// 文件大小
- (NSInteger)cq_fileSize;
// 经过编码之后的url
- (NSString *)cq_encodeURL;

@end

NS_ASSUME_NONNULL_END
