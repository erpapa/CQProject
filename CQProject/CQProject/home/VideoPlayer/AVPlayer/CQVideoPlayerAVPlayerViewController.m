//
//  CQVideoPlayerAVPlayerViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/2.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQVideoPlayerAVPlayerViewController.h"
#include <dlfcn.h>

@interface CQVideoPlayerAVPlayerViewController ()
@property (nonatomic, strong) id player;
@end

@implementation CQVideoPlayerAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self runtimePlay];
}

-(void)runtimePlay{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"01你拥有的最宝贵的财富是什么" ofType:@"mp3"];
    void *lib = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY);
    if(lib) {
        Class playerClass = NSClassFromString(@"AVAudioPlayer");
        SEL selector = NSSelectorFromString(@"initWithData:error:");
        _player = [[playerClass alloc] performSelector:selector withObject:[NSData dataWithContentsOfFile:path] withObject:nil];
        selector = NSSelectorFromString(@"play");
        [_player performSelector:selector];
        NSLog(@"动态加载库成功");
        
    }
}

@end
