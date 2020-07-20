//
//  CQTwoKVOViewController.h
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "CQBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class Person;
@interface CQTwoKVOViewController : CQBaseViewController
@property (nonatomic, strong) Person *p;
@end

NS_ASSUME_NONNULL_END
