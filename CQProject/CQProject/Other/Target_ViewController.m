//
//  Target_ViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/26.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "Target_kvoTwo.h"

@interface Target_kvoTwo ()

@end

@implementation Target_kvoTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"中间层创建的对象是%@，age的值是%d",self,self.age);
}

- (void)Action_setAge:(int)age {
    self.age = age;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
