//
//  UIButton+expand.h
//  CQProject
//
//  Created by CharType on 2020/7/21.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Expand)
@property (nonatomic, assign) CGFloat expandLeft;
@property (nonatomic, assign) CGFloat expandTop;
@property (nonatomic, assign) CGFloat expandRight;
@property (nonatomic, assign) CGFloat expandBottom;

@property (nonatomic, assign) UIEdgeInsets expandEdgeInsets;
@end

NS_ASSUME_NONNULL_END
