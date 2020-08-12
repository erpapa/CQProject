//
//  CQStudent.h
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQPerson.h"
@class CQWeakObject;

NS_ASSUME_NONNULL_BEGIN

@interface CQStudent : CQPerson
@property (nonatomic, weak) CQWeakObject *weakObject;
@end

NS_ASSUME_NONNULL_END
