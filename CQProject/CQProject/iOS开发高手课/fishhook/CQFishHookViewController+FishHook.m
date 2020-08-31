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
    struct rebinding ex;
    ex.name = "method_exchangeImplementations";
    ex.replacement = myExchange;
    ex.replaced = (void *)exhangeP;
    struct rebinding rebs[1] = {ex};
    rebind_symbols(rebs, 1);
}

void (*exhangeP)(Method _Nonnull m1,Method _Nonnull m2);

void myExchange(Method _Nonnull m1,Method _Nonnull m2) {
    struct rebinding nslog;
    nslog.name = "NSLog";
    nslog.replacement = myNslog;
    nslog.replaced = (void *)&sys_nslog;
    struct rebinding rebs[1] = {nslog};
    rebind_symbols(rebs, 1);
    NSLog(@"想搞事情");
}

static void(*sys_nslog)(NSString * format,...);

void myNslog(NSString * format,...) {
    format = [format stringByAppendingString:@"发现了非法操作\n"];
    sys_nslog(format);
}
@end
