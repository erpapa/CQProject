//
//  CQRuntimeSubViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/5.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRuntimeSubViewController.h"

@interface CQRuntimeSubViewController ()

@end

@implementation CQRuntimeSubViewController
+ (void)load {
    // 会崩溃
//    Method method1 = class_getInstanceMethod([self superclass], @selector(viewWillAppear:));
//    Method method2 = class_getInstanceMethod(self, @selector(test));
//    method_exchangeImplementations(method1, method2);
}

- (void)test {
    [self test2];
}

- (void)test2 {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
