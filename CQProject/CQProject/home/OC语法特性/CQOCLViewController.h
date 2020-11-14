//
//  CQOCLViewController.h
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQBaseViewController.h"
#import "CQWeakObject.h"

NS_ASSUME_NONNULL_BEGIN
static CQWeakObject *controllerWeakObject = nil;
@interface CQOCLViewController : CQBaseViewController
- (void)subBlockTest;
@end

NS_ASSUME_NONNULL_END
