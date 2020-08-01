//
//  CQWebViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/26.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQWebViewController.h"
#import <WebKit/WebKit.h>

@interface CQWebViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *wkwebView;
@end

@implementation CQWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.wkwebView];
    [self.wkwebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

- (WKWebView *)wkwebView {
    if (!_wkwebView) {
        _wkwebView = [[WKWebView alloc] init];
    }
    return _wkwebView;
}

@end
