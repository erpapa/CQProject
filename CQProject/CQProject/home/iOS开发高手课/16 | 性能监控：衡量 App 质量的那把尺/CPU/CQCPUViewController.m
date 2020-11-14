//
//  CQCPUViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/12.
//  Copyright © 2020 CharType. All rights reserved.
//

#include <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#include <mach/task.h>
#include <mach/vm_map.h>
#include <mach/mach_init.h>
#include <mach/thread_act.h>
#include <mach/thread_info.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/sysctl.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <dispatch/dispatch.h>
#import "CQCPUViewController.h"

@interface CQCPUViewController ()
@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) UILabel *memoryLabel;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CQCPUViewController
- (void)dealloc {
    [self.timer invalidate];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.cpuLabel];
    [self.cpuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(YYScreenSize().width, 30));
        make.center.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.memoryLabel];
    [self.memoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(YYScreenSize().width, 30));
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.cpuLabel.mas_bottom);
    }];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:[YYWeakProxy proxyWithTarget:self] selector:@selector(timerCallBack) userInfo:nil repeats:YES];
}

- (void)timerCallBack {
    self.cpuLabel.text = [NSString stringWithFormat:@"CPU:%d",[self cpuUsage] / 10];
    // 当CPU使用率超过80% 进行上报
    self.memoryLabel.text = [NSString stringWithFormat:@"内存:%ld",(long)memoryUsage()];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_queue_create("xiancheng", DISPATCH_QUEUE_CONCURRENT), ^{
//        sleep(10);
        for (int i = 0; i < 10000; i++) {
            NSLog(@"线上监控CPU使用率");
        }
    });
}

- (UILabel *)cpuLabel {
    if (!_cpuLabel) {
        _cpuLabel = [[UILabel alloc] init];
        _cpuLabel.textColor = [UIColor blackColor];
        _cpuLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _cpuLabel;
}

- (UILabel *)memoryLabel {
    if (!_memoryLabel) {
        _memoryLabel = [[UILabel alloc] init];
        _memoryLabel.textColor = [UIColor blackColor];
        _memoryLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _memoryLabel;
}


uint64_t memoryUsage() {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS)
        return 0;
    return vmInfo.phys_footprint;
}

- (integer_t)cpuUsage {
    thread_act_array_t threads; //int 组成的数组比如 thread[1] = 5635
    mach_msg_type_number_t threadCount = 0; //mach_msg_type_number_t 是 int 类型
    const task_t thisTask = mach_task_self();
    //根据当前 task 获取所有线程
    kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
    
    if (kr != KERN_SUCCESS) {
        return 0;
    }
    
    integer_t cpuUsage = 0;
    // 遍历所有线程
    for (int i = 0; i < threadCount; i++) {
        
        thread_info_data_t threadInfo;
        thread_basic_info_t threadBaseInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        
        if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            // 获取 CPU 使用率
            threadBaseInfo = (thread_basic_info_t)threadInfo;
            if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                cpuUsage += threadBaseInfo->cpu_usage;
            }
        }
    }
    assert(vm_deallocate(mach_task_self(), (vm_address_t)threads, threadCount * sizeof(thread_t)) == KERN_SUCCESS);
    return cpuUsage;
}
@end
