//
//  CQEnergyViewController.m
//  CQProject
//
//  Created by CharType on 2020/9/7.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQEnergyViewController.h"
//#import "IOPSKeys.h"
//#import "IOPowerSources.h"
#import "CQCallStack.h"


@interface CQEnergyViewController ()
@property (nonatomic, strong) UILabel  *energyLogLabel;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CQEnergyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电量消耗监控";
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [self.view addSubview:self.energyLogLabel];
    [self.energyLogLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    double deviceLevel = [self getBatteryLevel];
    self.energyLogLabel.text = [NSString stringWithFormat:@"当前电量:%1.f",deviceLevel];
    self.timer = [NSTimer timerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        [CQCallStack updateCPU];
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


-(double)getBatteryLevel{
    return [UIDevice currentDevice].batteryLevel;
    /*
    // 返回电量信息
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    // 返回电量句柄列表数据
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    CFDictionaryRef pSource = NULL;
    const void *psValue;
    // 返回数组大小
    int numOfSources = CFArrayGetCount(sources);
    // 计算大小出错处理
    if (numOfSources == 0) {
        NSLog(@"Error in CFArrayGetCount");
        return -1.0f;
    }

    // 计算所剩电量
    for (int i=0; i<numOfSources; i++) {
        // 返回电源可读信息的字典
        pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!pSource) {
            NSLog(@"Error in IOPSGetPowerSourceDescription");
            return -1.0f;
        }
        psValue = (CFStringRef) CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));

        int curCapacity = 0;
        int maxCapacity = 0;
        double percentage;

        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);

        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);

        percentage = ((double) curCapacity / (double) maxCapacity * 100.0f);
        NSLog(@"curCapacity : %d / maxCapacity: %d , percentage: %.1f ", curCapacity, maxCapacity, percentage);
        return percentage;
    }
    return -1;
     */
}

- (UILabel *)energyLogLabel {
    if (!_energyLogLabel) {
        _energyLogLabel = [[UILabel alloc] init];
    }
    return _energyLogLabel;
}
@end
