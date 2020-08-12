//
//  CQPackageViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/12.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQPackageViewController.h"

@interface CQPackageViewController ()

@end

@implementation CQPackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 包大小优化步骤
    // 1.资源优化
        // App Thinning 图片放到Assets中
        // 图片压缩
        // git图片转换成webP格式图片
           // 1. WebP 压缩率高，而且肉眼看不出差异，同时支持有损和无损两种压缩模式。比如，将 Gif 图转为 Animated WebP ，有损压缩模式下可减少 64% 大小，无损压缩模式下可减少 19% 大小。
           // 2. WebP 支持 Alpha 透明和 24-bit 颜色数，不会像 PNG8 那样因为色彩不够而出现毛边
          // 3.WebP 在 CPU 消耗和解码时间上会比 PNG 高两倍。所以，我们有时候还需要在性能和体积上做取舍
        // * 扫描无用的图片
    // 2.可执行文件优化
}

@end
