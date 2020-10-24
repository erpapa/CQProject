//
//  CQRootNavigationViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRootNavigationViewController.h"
//#import <dlfcn.h>

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

//void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
//                                                    uint32_t *stop) {
//  static uint64_t N;  // Counter for the guards.
//  if (start == stop || *start) return;  // Initialize only once.
//  printf("INIT: %p %p\n", start, stop);
//  for (uint32_t *x = start; x < stop; x++)
//    *x = ++N;  // Guards should start from 1.
//}
//
//void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//  if (!*guard) return;  // Duplicate the guard check.
//
//  void *PC = __builtin_return_address(0);
//  Dl_info info;
//  dladdr(PC, &info);
//  printf("sname=%s\n",info.dli_sname);
////  printf("fname=%s \nfbase=%p \nsname=%s\nsaddr=%p \n",info.dli_fname,info.dli_fbase,info.dli_sname,info.dli_saddr);
//
////  char PcDescr[1024];
//  //__sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
////  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
//}

@end
