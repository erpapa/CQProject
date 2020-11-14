//
//  NSFileManager+CQ.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (CQ)
- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;
@end

NS_ASSUME_NONNULL_END
