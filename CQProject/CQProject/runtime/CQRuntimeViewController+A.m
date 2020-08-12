//
//  CQRuntimeViewController+A.m
//  CQProject
//
//  Created by CharType on 2020/8/4.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRuntimeViewController+A.h"

@implementation CQRuntimeViewController (A)
//+ (void)load {
//    NSLog(@"runtime分类A中的+load方法被调用");
//    Method method1 = class_getInstanceMethod(self, @selector(viewWillAppear:));
//    Method method2 = class_getInstanceMethod(self, @selector(A_viewWillAppear));
//    method_exchangeImplementations(method1, method2);
//}

- (void)A_viewWillAppear {
    NSLog(@"调用了A类中交换过后的方法");
    [self A_viewWillAppear];
}
@end
