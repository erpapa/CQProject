//
//  CQWeakObject.m
//  CQProject
//
//  Created by CharType on 2020/8/10.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQWeakObject.h"
#import "CQOCLViewController.h"

@implementation CQWeakObject

- (void)dealloc {
    controllerWeakObject = self;
}

- (void)test {
    NSLog(@"%s",__func__);
}

@end
