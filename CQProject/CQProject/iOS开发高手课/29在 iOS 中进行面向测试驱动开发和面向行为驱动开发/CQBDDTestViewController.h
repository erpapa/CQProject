//
//  CQBDDTestViewController.h
//  CQProject
//
//  Created by CharType on 2020/8/7.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQBaseViewController.h"
@class Person;

NS_ASSUME_NONNULL_BEGIN

@interface CQBDDTestViewController : CQBaseViewController
- (int)addnum1:(int)num1 num2:(int)num2;
- (int)lengthOfLongestSubstring:(NSString *)str;
- (NSObject *)objWithIndex:(NSInteger)index;
- (NSObject *)objWithIndex:(NSInteger)index objs:(NSArray *)objs;
- (Person *)getPersion;
@end

NS_ASSUME_NONNULL_END
