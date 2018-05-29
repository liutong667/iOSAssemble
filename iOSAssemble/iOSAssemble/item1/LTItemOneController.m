//
//  LTItemOneController.m
//  iOSAssemble
//
//  Created by liutong on 2018/4/7.
//  Copyright © 2018年 liutong. All rights reserved.
//

#import "LTItemOneController.h"
#import "GCDTestController.h"
#import "NSOperationTestVC.h"
#import "ImageDownTableVC.h"

@interface LTItemOneController ()
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *vcArr;
@end

@implementation LTItemOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr = @[@"弹窗半屏关闭手势",
                     @"GCD",
                     @"NSOperation",
                     @"ImageDownTableVC"
                       ];
    self.vcArr = @[NSStringFromClass([UIViewController class]),
                   NSStringFromClass([GCDTestController class]),
                   NSStringFromClass([NSOperationTestVC class]),
                   NSStringFromClass([ImageDownTableVC class]),
                     ];
    
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndentify = @"testCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class vcClass = NSClassFromString(self.vcArr[indexPath.row]);
    UIViewController *vc = [[vcClass alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -
- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSArray array];
    }
    return _dataArr;
}
-(NSArray *)vcArr{
    if (!_vcArr) {
        _vcArr = [NSArray array];
    }
    return _vcArr;
}

@end
