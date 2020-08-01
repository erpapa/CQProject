//
//  CQOCLViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQOCLViewController.h"
#import "CQPerson.h"

@interface CQOCLViewController ()

@end

@implementation CQOCLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CQPerson *p = [CQPerson modelWithJSON:@{@"name":@"aaa"}];
    CQPerson *p2 = [CQPerson modelWithJSON:@{@"name1":@"aaa"}];
    CQPerson *p3 = [CQPerson modelWithJSON:@{@"name2":@"aaa"}];
    CQPerson *p4 = [CQPerson modelWithJSON:@{@"name3":@"aaa"}];
    NSLog(@"哈哈哈哈哈");
//    [NSTimer scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
//        
//    } repeats:YES];
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
