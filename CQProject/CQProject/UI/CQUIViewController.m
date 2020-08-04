//
//  CQUIViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQUIViewController.h"
typedef  void (^MyBlock)(void);

@interface CQUIViewController ()
@property (nonatomic, strong) UIView *custemView;
@property (nonatomic, strong) NSString *str;
@property (nonatomic, copy) NSMutableArray *array;
@property (nonatomic, strong) UIControl *control;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWindow *window2;
@property (nonatomic, strong) MyBlock block;
@property (nonatomic, strong) UIButton *button;
@end

@implementation CQUIViewController
- (void)dealloc {
    NSLog(@"%s",__func__);
}

int a = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    __block int b = 10;
    self.block = ^{
        NSLog(@"%d", b);
    };
    
    [self buttonTest];
    
    
//    BOOL iscache = [YYKeychain setPassword:@"123456" forService:@"com.ashaj.chengqian" account:@"CharType"];
    NSLog(@"%s",__func__);
//    dispatch_queue_get_label(<#dispatch_queue_t  _Nullable queue#>)
    
    
}

- (void)buttonTest {
    self.button = [[UIButton alloc] init];
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    self.button.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        NSLog(@"手势1响应了");
    }];
    UITapGestureRecognizer *gest2 = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        NSLog(@"手势2响应了");
    }];
    [self.button addGestureRecognizer:gest2];
    [self.button addGestureRecognizer:gest];
    
    
//    [self.button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick {
    NSLog(@"button被点击了");
}

- (void)testWindow {
    NSLog(@"最开始的keyWindow：%@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"最开始的Appdelegate的Window：%@",[UIApplication sharedApplication].delegate.window);
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.window.rootViewController = [[UIViewController alloc] init];
    self.window.windowLevel = 10;
    [self.window makeKeyAndVisible];
    NSLog(@"创建window的值：%@",self.window);
    NSLog(@"创建window并且make之后的keyWindow：%@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"创建window并且make之后的的Appdelegate的Window：%@",[UIApplication sharedApplication].delegate.window);


    self.window2 = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.window2.rootViewController = [[UIViewController alloc] init];
    self.window2.windowLevel = 11;
    [self.window2 makeKeyAndVisible];
    NSLog(@"创建window2的值：%@",self.window2);
    NSLog(@"创建window2并且make之后的keyWindow：%@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"创建window2并且make之后的的Appdelegate的Window：%@",[UIApplication sharedApplication].delegate.window);

    [self.window2 removeFromSuperview];
    self.window2 = nil;
    NSLog(@"window2删除置空之后的keyWindow：%@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"window2删除置空之后的的Appdelegate的Window：%@",[UIApplication sharedApplication].delegate.window);
       
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"测试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [alertView show];
    NSLog(@"alertView弹出之后的keyWindow：%@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"alertView弹出之后的Appdelegate的Window：%@",[UIApplication sharedApplication].delegate.window);
    
    [self.window removeFromSuperview];
    self.window = nil;
    NSLog(@"window删除置空之后的keyWindow：%@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"window删除置空之后的的Appdelegate的Window：%@",[UIApplication sharedApplication].delegate.window);
}

- (void)test {
    self.custemView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.custemView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.custemView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        NSLog(@"view被点击到了");
    }];
    [self.custemView addGestureRecognizer:tap];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CALayer *layer = self.custemView.layer;
//    layer.frame = CGRectMake(100, 100, 200, 200);
    layer.width = 200;
    layer.height = 200;
}

- (NSObject *)getTempObject {
    return [self getAssociatedValueForKey:@selector(getTempObject)];
}

- (void)setTempObject:(NSObject *)tempObject {
    [self setAssociateWeakValue:tempObject withKey:@selector(getTempObject)];
}

//+ (BOOL)getProxyStatus {
//    NSDictionary *proxySettings = NSMakeCollectable([(NSDictionary *)CFNetworkCopySystemProxySettings() autorelease]);
//    NSArray *proxies = NSMakeCollectable([(NSArray *)CFNetworkCopyProxiesForURL((CFURLRef)[NSURL URLWithString:@"http://www.google.com"], (CFDictionaryRef)proxySettings) autorelease]);
//    NSDictionary *settings = [proxies objectAtIndex:0];
//
//    NSLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]);
//    NSLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
//    NSLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]);
//
//    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"])
//    {
//        //没有设置代理
//        return NO;
//    }
//    else
//    {
//        //设置代理了
//        return YES;
//    }
//}

- (UIControl *)contrrol {
    if (!_control) {
        
    }
    return _control;
}

@end
