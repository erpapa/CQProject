//
//  CQRuntimeViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/4.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRuntimeViewController.h"

@interface CQRuntimeViewController ()

@end

@implementation CQRuntimeViewController
+ (void)load {
    NSLog(@"runtime主类中的+load方法被调用");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"主类中的方法被调用");
}

@end
