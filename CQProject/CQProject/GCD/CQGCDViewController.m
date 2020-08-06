//
//  CQGCDViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/22.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQGCDViewController.h"
#import "CQOperation.h"

@interface CQGCDViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation CQGCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GCD";
    self.lock = [[NSLock alloc] init];
    self.semaphore = dispatch_semaphore_create(1);
//    [self test8];
    
    // 已经在主队列中重复执行任务
//    [self locktest];
    //
//    [self locktest1];
//    [self locktest3];
    [self locktest4];
    
}

- (void)locktest4 {
    // 信号量的使用不当死锁
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    sleep(3);
    dispatch_semaphore_signal(self.semaphore);
}

- (void)locktest3 {
    // 同一个线程重复去获取锁 这个时候应该使用递归锁 或者 @synchronized
    // 使用互斥锁的时候一个线程获取锁之后，做完任务 没有去释放锁，也会有这种问题
    [self.lock lock];
    [self locktest2];
    [self.lock unlock];
}

- (void)locktest2 {
    [self.lock lock];
    sleep(3);
    [self.lock unlock];
}
- (void)locktest1 {
    // 已经在串行队列执行的过程中同步在这个串行队列中执行任务
    dispatch_queue_t queue = dispatch_queue_create("死锁线程", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        dispatch_sync(queue, ^{
            NSLog(@"死锁啦");
        });
    });
}

- (void)locktest {
    // 在主线程中同步在主队列执行任务
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"死锁了");
    });
}

- (void)test8 {
    [self performSelector:@selector(test) withObject:nil afterDelay:1];
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
//        sleep(3);
        NSLog(@"1 %@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
//        sleep(1);
        NSLog(@"2 %@",[NSThread currentThread]);
    });
//
    dispatch_sync(queue, ^{
        NSLog(@"4 %@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"5 %@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"6 %@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"7 %@",[NSThread currentThread]);
    });
//
//    dispatch_sync(queue, ^{
////        sleep(5);
//        NSLog(@"4 %@",[NSThread currentThread]);
//    });
//
//    dispatch_async(queue, ^{
//        NSLog(@"5 %@",[NSThread currentThread]);
//    });
//    NSLog(@"6");
    
//    2、4、6、3、5、1

}

- (void)test7 {
    NSLog(@"%s",__func__);
}

- (void) test6 {
    // GCD的多读，单写的Api的使用
    // 获取全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 20; i++) {
        dispatch_async(globalQueue, ^{
            NSLog(@"正在进行读数据的操作 %d",i);
            [NSThread sleepForTimeInterval:0.5];
        });
        if (i % 3 == 0) {
            dispatch_barrier_async(globalQueue, ^{
                NSLog(@"正在进行写入数据的操作 %d",i);
                [NSThread sleepForTimeInterval:0.5];
            });
        }
    }
//    for (int i = 0; i < 10; i++) {
//        dispatch_barrier_sync(globalQueue, ^{
//            NSLog(@"正在进行写入数据的操作");
//            [NSThread sleepForTimeInterval:0.5];
//        });
//    }
}

- (void)test5 {
    // 假如10个网络请求并发执行，最大并发量是3个，10个网络请求都执行完了在同一的处理，假如其中的4，5，6 三个任务必须要顺序执行 (回答： （GCDGroup + 信号量 + 并发队列 + 串行队列)
    // 获取全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    // 创建group组
    dispatch_group_t group = dispatch_group_create();
    // 创建信号量
    dispatch_semaphore_t sem = dispatch_semaphore_create(3);
    // 串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务1 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务2 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务3 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, serialQueue, ^{
       NSLog(@"正在执行任务4 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, serialQueue, ^{
       NSLog(@"正在执行任务5 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, serialQueue, ^{
       NSLog(@"正在执行任务6 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务7 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务8 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务9 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, globalQueue, ^{
       NSLog(@"正在执行任务10 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"所有的任务都执行完成了 %@",[NSThread currentThread]);
    });
}

- (void)test4 {
    // 假如10个网络请求并发执行，最大并发量是3个，10个网络请求都执行完了在同一的处理（GCDGroup + 信号量）
    // 获取全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    // 创建group组
    dispatch_group_t group = dispatch_group_create();
    // 创建信号量
    dispatch_semaphore_t sem = dispatch_semaphore_create(3);
    for (int i = 0; i < 10; i++) {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, globalQueue, ^{
           NSLog(@"正在执行任务%d %@",i,[NSThread currentThread]);
            [NSThread sleepForTimeInterval:1];
            dispatch_semaphore_signal(sem);
        });
    }
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"所有的任务都执行完成了 %@",[NSThread currentThread]);
    });
}

- (void)test3 {
    // 假如10个网络请求并发执行，最大并发量是3个，你怎么做 使用GCD 和NSoperation都可以
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t sem = dispatch_semaphore_create(3);
    for (int i = 0; i < 10; i++) {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_async(globalQueue, ^{
            NSLog(@"正在执行任务%d %@",i,[NSThread currentThread]);
            [NSThread sleepForTimeInterval:1];
            dispatch_semaphore_signal(sem);
        });
    }
}

- (void)test2 {
    // 异步执行的时候 串行执行5个任务 要求第三个任务是在主线程执行
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_queue_t serialQueue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    dispatch_async(globalQueue, ^{
        dispatch_sync(serialQueue, ^{
            NSLog(@"任务1执行完成 %@",[NSThread currentThread]);
        });
        
        dispatch_sync(serialQueue, ^{
            NSLog(@"任务2执行完成 %@", [NSThread currentThread]);
        });
        
        dispatch_sync(serialQueue, ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"任务3执行完成 %@", [NSThread currentThread]);
            });
        });
        
        dispatch_sync(serialQueue, ^{
            NSLog(@"任务4执行完成%@",[NSThread currentThread]);
        });
        
        dispatch_sync(serialQueue, ^{
            NSLog(@"任务5执行完成%@",[NSThread currentThread]);
        });
    });
}

- (void)test1 {
    // 异步执行10个任务会创建10个线程吗？
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    for (int i = 0;i < 10; i++) {
        dispatch_async(globalQueue, ^{
            NSLog(@"%d,---%@",i,[NSThread currentThread]);
        });
    }
}

- (void)queueTest {
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 10;
    CQOperation *operation = [[CQOperation alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.queue cancelAllOperations];
    });
    
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        @strongify(blockOperation);
        for (int i = 0; i < 10000; i++) {
            if (blockOperation.isCancelled) {
                return;
            }
            NSLog(@"%d",i);
        }
    }];
    [self.queue addOperation:operation];
    [self.queue addOperation:blockOperation];
}

- (void)test {
    dispatch_queue_t serialqueue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t currentqueue = dispatch_queue_create("test",DISPATCH_QUEUE_CONCURRENT);
        for (int i = 1;i<= 10;i++) {
            
    //        dispatch_async(serialqueue, ^{
    //            NSLog(@"%d",i);
    //        });
            
            dispatch_sync(currentqueue, ^{
                NSLog(@"%d",i);
            });
        }
}

@end
