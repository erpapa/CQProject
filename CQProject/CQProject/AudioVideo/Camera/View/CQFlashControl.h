//
//  CQFlashControl.h
//  CQProject
//
//  Created by CharType on 2020/9/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CQFlashControlDelegate <NSObject>

@optional
- (void)flashControlWillExpand;
- (void)flashControlDidExpand;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

@interface CQFlashControl : UIControl
@property (nonatomic, assign) NSInteger selectedMode;
@property (weak, nonatomic) id<CQFlashControlDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
