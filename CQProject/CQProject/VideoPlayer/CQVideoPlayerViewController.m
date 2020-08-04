//
//  CQVideoPlayerViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/2.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQVideoPlayerViewController.h"
#import "RETableViewManager.h"
#import "CQVideoPlayerAVPlayerViewController.h"

@interface CQVideoPlayerViewController ()
@property (strong, nonatomic) RETableViewManager *tableManager;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) RETableViewSection *section;
@end

@implementation CQVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频播放器";
    [self.tableManager addSection:self.section];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.height.equalTo(self.view);
    }];
    
    @weakify(self);
    RETableViewItem *ocItem = [[RETableViewItem alloc] initWithTitle:@"AVPlayer"];
        ocItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQVideoPlayerAVPlayerViewController *viewControlleer = [[CQVideoPlayerAVPlayerViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:ocItem];
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
