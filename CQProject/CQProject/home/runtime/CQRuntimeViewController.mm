//
//  CQRuntimeViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/4.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRuntimeViewController.h"
#include <objc/runtime.h>
#import "MJClassInfo.h"
#include <string.h>

#define RW_INITIALIZED        (1<<29)

@interface CQRuntimeViewController ()

@end

@implementation CQRuntimeViewController
//+ (void)load {
//    NSLog(@"runtime主类中的+load方法被调用");
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取所有的类，判断哪些类没有被初始化过
    
    int numClasses = 0, newNumClasses = objc_getClassList(NULL, 0); // 1
    Class *classes = NULL; // 2
    while (numClasses < newNumClasses) { // 3
        numClasses = newNumClasses; // 4
        classes = (Class *)realloc(classes, sizeof(Class) * numClasses); // 5
        newNumClasses = objc_getClassList(classes, numClasses); // 6
        for (int i = 0; i < numClasses; i++) { // 7
            const char *className = class_getName(classes[i]); // 8
            mj_objc_class *objClass = (__bridge mj_objc_class *)(classes[i]);
            if(strcmp(className, "CQRuntimeViewController") == 0 ) {
                NSLog(@"是当前这个类");
                
                method_list_t * methods = objClass->data()->methods;
            }
            bool res = objClass->data()->flags & RW_INITIALIZED;
            NSLog(@"%s -> 是否初始化过%d", className,res); // 9
            
        } // 10
        
    } // 11
    free(classes); // 12
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"主类中的方法被调用");
}

@end
