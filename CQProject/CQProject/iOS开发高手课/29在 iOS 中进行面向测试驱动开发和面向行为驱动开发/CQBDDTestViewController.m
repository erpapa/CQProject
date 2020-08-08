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
 
@end
