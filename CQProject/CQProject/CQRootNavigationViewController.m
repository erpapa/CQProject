//
//  CQRootNavigationViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRootNavigationViewController.h"

@interface CQRootNavigationViewController ()

@end

@implementation CQRootNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count==1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
