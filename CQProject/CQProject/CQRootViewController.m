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
    
    RETableViewItem *kvoItem = [[RETableViewItem alloc] initWithTitle:@"KVO"];
    @weakify(self);
    kvoItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        Class cls = NSClassFromString(@"NSKVONotifying_CQKVOViewController");
        
        CQKVOViewController *viewControlleer = [[CQKVOViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:kvoItem];
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
