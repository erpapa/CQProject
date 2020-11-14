//
//  CQFishHookViewController+FishHook.m
//  CQProject
//
//  Created by CharType on 2020/8/31.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQFishHookViewController+FishHook.h"
#import <objc/runtime.h>
#import <fishhook/fishhook.h>

@implementation CQFishHookViewController (FishHook)
+(void)load {
    /**
     
     */
   
}

- (void)bindExchangeMethod {
    struct rebinding ex;
       // 需要hook的函数名 C字符串
       ex.name = "method_exchangeImplementations";
       // 新的函数地址
       ex.replacement = myExchange;
       // 指向原函数地址
       ex.replaced = (void *)&exhangeP;
       // rebinding结构体数组
       struct rebinding rebs[1] = {ex};
       int isbind = rebind_symbols(rebs, 1);
       if (isbind == 0) {
           NSLog(@"绑定成功");
       } else {
           NSLog(@"绑定失败");
       }
}

void (*exhangeP)(Method _Nonnull m1,Method _Nonnull m2);

void myExchange(Method _Nonnull m1,Method _Nonnull m2) {
    // hookNSlog
    struct rebinding nslog;
    nslog.name = "NSLog";
    // 新的函数地址
    nslog.replacement = myNslog;
    // 指向原来的函数地址
    nslog.replaced = (void *)&sys_nslog;
    struct rebinding rebs[1] = {nslog};
    rebind_symbols(rebs, 1);
    NSLog(@"想搞事情");
}

void(*sys_nslog)(NSString * format,...);


void myNslog(NSString * format,...) {
    format = [format stringByAppendingString:@"发现了非法操作\n"];
    // 调用原来系统的NSLog方法
    sys_nslog(format);
}
@end
