//
//  ViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQRootViewController.h"
#import "RETableViewManager.h"
#import "Masonry.h"
#import "YYKit.h"
#import "CQKVOViewController.h"
#import "CQGestureRecognizerViewController.h"
#import "CQComponentViewController.h"
#import "CQGCDViewController.h"
#import "CQUIViewController.h"
#import "CQOCLViewController.h"

@interface CQRootViewController ()<RETableViewManagerDelegate>
@property (strong, nonatomic) RETableViewManager *tableManager;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) RETableViewSection *section;
@end

@implementation CQRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableManager addSection:self.section];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.height.equalTo(self.view);
    }];
    
    
    @weakify(self);
     RETableViewItem *ocItem = [[RETableViewItem alloc] initWithTitle:@"OC语法特性"];
        ocItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQOCLViewController *viewControlleer = [[CQOCLViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:ocItem];
    
    RETableViewItem *kvoItem = [[RETableViewItem alloc] initWithTitle:@"KVO"];
    kvoItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
//        Class cls = NSClassFromString(@"NSKVONotifying_CQKVOViewController");
        
        CQKVOViewController *viewControlleer = [[CQKVOViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:kvoItem];
    
    RETableViewItem *gestureRecognizerItem = [[RETableViewItem alloc] initWithTitle:@"手势事件"];
    gestureRecognizerItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQGestureRecognizerViewController *viewControlleer = [[CQGestureRecognizerViewController alloc] init];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:gestureRecognizerItem];
    
    RETableViewItem *dataItem = [[RETableViewItem alloc] initWithTitle:@"数据结构"];
    dataItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        
    };
    [self.section addItem:dataItem];
    
    RETableViewItem *componentItem = [[RETableViewItem alloc] initWithTitle:@"组件化中间层"];
    componentItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQComponentViewController *viewController = [[CQComponentViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:componentItem];
    
    RETableViewItem *gcdItem = [[RETableViewItem alloc] initWithTitle:@"GCD"];
    gcdItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQGCDViewController *viewController = [[CQGCDViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:gcdItem];
    
    RETableViewItem *UIItem = [[RETableViewItem alloc] initWithTitle:@"UI"];
    UIItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQUIViewController *viewController = [[CQUIViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:UIItem];
    
    [self.tableView reloadData];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    return _tableView;
}
- (RETableViewManager *)tableManager {
    if (!_tableManager) {
        _tableManager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    }
    return _tableManager;
}
- (RETableViewSection *)section {
    if (!_section) {
        _section = [[RETableViewSection alloc] init];
        _section.headerHeight = CGFLOAT_MIN;
        _section.footerHeight = CGFLOAT_MIN;
    }
    return _section;
}

@end
