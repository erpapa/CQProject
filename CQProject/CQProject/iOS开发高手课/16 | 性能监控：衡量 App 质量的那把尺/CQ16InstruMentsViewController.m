//
//  CQ16InstruMentsViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/12.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQ16InstruMentsViewController.h"
#import "CQFPSViewController.h"
#import "CQCPUViewController.h"
#import "CQEnergyViewController.h"

@interface CQ16InstruMentsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *tableManager;
@property (nonatomic, strong) RETableViewSection *section;
@end

@implementation CQ16InstruMentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    [self.tableManager addSection:self.section];
    
    RETableViewItem *item = [[RETableViewItem alloc] initWithTitle:@"线上监控FPS"];
    @weakify(self);
    item.selectionHandler = ^(id item) {
        @strongify(self);
        CQFPSViewController *vc = [[CQFPSViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    [self.section addItem:item];
    
    RETableViewItem *cpuItem = [[RETableViewItem alloc] initWithTitle:@"线上CPU监控和内存监控"];
    cpuItem.selectionHandler = ^(id item) {
        @strongify(self);
        CQCPUViewController *vc = [[CQCPUViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    [self.section addItem:cpuItem];
    
    RETableViewItem *energyItem = [[RETableViewItem alloc] initWithTitle:@"电量消耗监控"];
    energyItem.selectionHandler = ^(id item) {
        @strongify(self);
        CQEnergyViewController *vc = [[CQEnergyViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    [self.section addItem:energyItem];
    
    
}

- (RETableViewManager *)tableManager {
    if (!_tableManager) {
        _tableManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    }
    return _tableManager;
}

- (RETableViewSection *)section {
    if (!_section) {
        _section = [[RETableViewSection alloc] init];
    }
    return _section;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    return _tableView;
}

@end
