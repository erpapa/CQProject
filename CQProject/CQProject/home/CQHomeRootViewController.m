//
//  ViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQHomeRootViewController.h"
#import "Masonry.h"
#import "YYKit.h"
#import "CQKVOViewController.h"
#import "CQGestureRecognizerViewController.h"
#import "CQComponentViewController.h"
#import "CQGCDViewController.h"
#import "CQUIViewController.h"
#import "CQOCLViewController.h"
#import "CQRunLoopViewController.h"
#import "CQWebViewController.h"
#import "YYFPSLabel.h"
#import "CQDownloadTestViewController.h"
#import "CQVideoPlayerViewController.h"
#import "CQRuntimeViewController.h"
#import "CQiOSDevelopmentViewController.h"

@interface CQHomeRootViewController ()<RETableViewManagerDelegate>
@property (strong, nonatomic) RETableViewManager *tableManager;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) RETableViewSection *section;
@end

@implementation CQHomeRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self rac_willDeallocSignal] subscribeNext:^(id x) {
        
    }];
    self.title = @"首页";
//    YYFPSLabel *label = [[YYFPSLabel alloc] initWithFrame:CGRectMake(10, 10, 60, 20)];
//    [self.navigationController.view addSubview:label];
//    [self.navigationController.view bringSubviewToFront:label];
    [self.tableManager addSection:self.section];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.height.equalTo(self.view);
    }];
    
    
    @weakify(self);
    RETableViewItem *iOSDecelopmentItem = [[RETableViewItem alloc] initWithTitle:@"iOS优化"];
        iOSDecelopmentItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQiOSDevelopmentViewController *viewControlleer = [[CQiOSDevelopmentViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:iOSDecelopmentItem];
    
     RETableViewItem *ocItem = [[RETableViewItem alloc] initWithTitle:@"OC语法特性"];
        ocItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQOCLViewController *viewControlleer = [[CQOCLViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:ocItem];
    
    RETableViewItem *webViewItem = [[RETableViewItem alloc] initWithTitle:@"H5交互"];
        webViewItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQWebViewController *viewControlleer = [[CQWebViewController alloc] init];
        viewControlleer.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:viewControlleer animated:YES];
    };
    [self.section addItem:webViewItem];
    
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
    
    RETableViewItem *runtimeItem = [[RETableViewItem alloc] initWithTitle:@"runtime"];
    runtimeItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQRuntimeViewController *viewController = [[CQRuntimeViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:runtimeItem];
    
    RETableViewItem *runLoopItem = [[RETableViewItem alloc] initWithTitle:@"RunLoop"];
    runLoopItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQRunLoopViewController *viewController = [[CQRunLoopViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:runLoopItem];
    
    RETableViewItem *downloadItem = [[RETableViewItem alloc] initWithTitle:@"下载功能"];
    downloadItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQDownloadTestViewController *viewController = [[CQDownloadTestViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:downloadItem];
    
    RETableViewItem *videoPlayerItem = [[RETableViewItem alloc] initWithTitle:@"视频播放功能"];
    videoPlayerItem.selectionHandler = ^(RETableViewItem *item) {
        @strongify(self);
        item.selectionStyle = UITableViewCellSelectionStyleNone;
        CQVideoPlayerViewController *viewController = [[CQVideoPlayerViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    };
    [self.section addItem:videoPlayerItem];
    
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
