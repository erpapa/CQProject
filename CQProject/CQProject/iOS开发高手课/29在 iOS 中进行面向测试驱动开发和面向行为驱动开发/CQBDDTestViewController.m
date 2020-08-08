//
//  CQBDDTestViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/7.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQBDDTestViewController.h"

@interface CQBDDTestViewController ()

@end

@implementation CQBDDTestViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"单元测试";
}

- (int)addnum1:(int)num1 num2:(int)num2 {
    return num1 + num2;
}

- (int)lengthOfLongestSubstring:(NSString *)str {
    if (str == nil ||str.length == 0) return 0;
    NSMutableArray *prevArrrays = [NSMutableArray arrayWithCapacity:128];
    for (int i = 0; i < 128; i++) {
        [prevArrrays addObject:@(-1)];
    }
    NSInteger li = 0;
    int maxLen = 1;
    prevArrrays[[str characterAtIndex:0]] = @(0);
    for (int i = 0; i < str.length; i++) {
        NSInteger prevIndex = [prevArrrays[[str characterAtIndex:i]] integerValue];
        if (prevIndex >= li) {
            li = prevIndex + 1;
        }
        maxLen = (int)MAX(maxLen, i - li + 1);
        prevArrrays[[str characterAtIndex:i]] = @(i);
    }
    return maxLen;
}
 
@end
