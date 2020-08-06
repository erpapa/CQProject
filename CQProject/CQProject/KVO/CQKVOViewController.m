//
//  CQKVOViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQKVOViewController.h"
#import "NSObject+CQKVO.h"
#import "Person.h"
#import "CQTwoKVOViewController.h"

@interface CQKVOViewController ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Person *p;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *name999;
@end

@implementation CQKVOViewController
- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"name"];
    NSLog(@"%s",__func__);
}

- (void)runTests
{
    Class class = NSClassFromString(@"NSKVONotifying_CQKVOViewController");
    unsigned int count;
    Method *methods = class_copyMethodList(class, &count);
    for (int i = 0; i < count; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        NSLog(@"方法 名字 ==== %@",name);
       
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KVO";
    self.p = [[Person alloc] init];
    self.p.p1 = [[Person alloc] init];
    [self szy_addObserverBlockForKeyPath:@"p.p1.age" block:^(id  _Nonnull obj, id  _Nonnull oldVal, id  _Nonnull newVal) {
        NSLog(@"触发了KVO监听");
    }];
    [self runTests];
    
    
    
//    self addObserver:self.p forKeyPath:@"name" options:<#(NSKeyValueObservingOptions)#> context:<#(nullable void *)#>
    
    
//    [self szy_addObserverBlockForKeyPath:@"p" block:^(id  _Nonnull obj, id  _Nonnull oldVal, id  _Nonnull newVal) {
//        NSLog(@"对象属性触发了KVO监听");
//    }];
    
    
    self.button = [[UIButton alloc] init];
    [self.view addSubview:self.button];
    [self.button setTitle:@"push" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 200));
    }];
    [self.button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    // 第一个参数是添加监听者
    // 第二个是回调者
//    [self.p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.name = @"哈哈哈哈";
    self.p.p1.age = 20;
//    self.p = [[Person alloc] init];
//    self.p.age = 30;
}

- (void)buttonClick {
    CQTwoKVOViewController *vc = [[CQTwoKVOViewController alloc] init];
    vc.p = self.p;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"触发了Kvo");
}

@end
