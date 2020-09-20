//
//  CQRuntimeViewController+B.m
//  CQProject
//
//  Created by CharType on 2020/8/4.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRuntimeViewController+B.h"

@implementation CQRuntimeViewController (B)
//+ (void)load {
//    NSLog(@"runtime分类B中的+load方法被调用");
//    Method method1 = class_getInstanceMethod(self, @selector(viewWillAppear:));
//    Method method2 = class_getInstanceMethod(self, @selector(B_viewWillAppear));
//    method_exchangeImplementations(method1, method2);
//}

- (void)B_viewWillAppear {
    NSLog(@"调用了B类中交换过后的方法");
    [self B_viewWillAppear];
}
@end
