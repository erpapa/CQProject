//
//  CQFishHookViewController.m
//  
//
//  Created by CharType on 2020/8/28.
//

#import "CQFishHookViewController.h"
#import <fishhook/fishhook.h>

@interface CQFishHookViewController ()
@end

@implementation CQFishHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"还没有被绑定");
//    [self hookLog];
    NSLog(@"老司机");
}

- (void)hookLog {
//    struct rebinding nslog;
//    nslog.name = "NSLog";
//    nslog.replacement = myNslog;
//    nslog.replaced = (void *)&sys_nslog;
//    struct rebinding rebs[1] = {nslog};
//    rebind_symbols(rebs, 1);
}

//static void(*sys_nslog)(NSString * format,...);
//
//void myNslog(NSString * format,...) {
//    format = [format stringByAppendingString:@"hook之后"];
//    sys_nslog(format);
//}

@end
