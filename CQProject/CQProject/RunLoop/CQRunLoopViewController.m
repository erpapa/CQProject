//
//  CQRunLoopViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/30.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRunLoopViewController.h"

@interface CQRunLoopViewController ()
//@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation CQRunLoopViewController

- (void)dealloc {
//    [self.link invalidate];
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc] init];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.textView.text = @"hahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahhhahahhahhahahhahh";
    [self addRunLoopObserver];
//    [NSTimer scheduledTimerWithTimeInterval:2 block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"block的任务执行");
//    } repeats:YES];
//    CATiledLayer 和 DownSampling
    
//    [self test1];
    
    
}

- (void)test1 {
//    self.link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(displayLink)];
//    NSLog(@"%@",[NSRunLoop currentRunLoop]);
//    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    NSLog(@"%@",[NSRunLoop currentRunLoop]);
    
}

- (void)displayLink {
    NSLog(@"哈哈哈哈");
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if ([self.link isPaused]) {
//        self.link.paused = YES;
////        [self.link performSelector:@selector(resume)];
//    } else {
////        [self.link performSelector:@selector(isPaused)];
//        self.link.paused = NO;
//    }
//    [self.link invalidate];
}

- (void)test8 {
//    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        sleep(3);
        NSLog(@"1 %@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        sleep(1);
        NSLog(@"2 %@",[NSThread currentThread]);
    });

    dispatch_async(queue, ^{
        NSLog(@"3 %@",[NSThread currentThread]);
    });

    dispatch_sync(queue, ^{
        sleep(5);
        NSLog(@"4 %@",[NSThread currentThread]);
    });

    dispatch_async(queue, ^{
        NSLog(@"5 %@",[NSThread currentThread]);
    });
    NSLog(@"6");
    
//    2、4、6、3、5、1

}

- (void)addRunLoopObserver {
    //创建一个观察者
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    CFRunLoopObserverRef runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                 kCFRunLoopAllActivities,
                                                 YES,
                                                 0,
                                                 &runLoopObserverCallBack,
                                                 &context);
    //将观察者添加到主线程runloop的common模式下的观察中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserver, kCFRunLoopCommonModes);
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    switch (activity) {
        case kCFRunLoopEntry: {
            NSLog(@"runloop进入 状态：kCFRunLoopEntry Model = %@",[NSRunLoop currentRunLoop].currentMode);
        }
            
            break;
        case kCFRunLoopBeforeTimers: {
            NSLog(@"runloop处理Timer 状态：kCFRunLoopBeforeTimers Model = %@",[NSRunLoop currentRunLoop].currentMode);
        }
                       
            break;
        case kCFRunLoopBeforeSources: {
            NSLog(@"runloop处理Sources 状态：kCFRunLoopBeforeSources Model = %@",[NSRunLoop currentRunLoop].currentMode);
        }
                       
            break;
        case kCFRunLoopBeforeWaiting: {
            NSLog(@"runloop即将休眠 状态：kCFRunLoopBeforeWaiting Model = %@",[NSRunLoop currentRunLoop].currentMode);
        }
                       
            break;
        case kCFRunLoopAfterWaiting: {
            NSLog(@"runloop从休眠中唤醒 状态：kCFRunLoopAfterWaiting Model = %@",[NSRunLoop currentRunLoop].currentMode);
        }
            break;
        case kCFRunLoopExit: {
            NSLog(@"runloop退出 状态：kCFRunLoopExit Model = %@",[NSRunLoop currentRunLoop].currentMode);
        }
            break;
     
            
        default:
            break;
            
    }
}

@end