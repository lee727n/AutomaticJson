//
//  AppDelegate.m
//  AutomaticModel
//
//  Created by 刘梓轩 on 2018/11/27.
//  Copyright © 2018年 刘梓轩. All rights reserved.
//


#import "ViewController.h"
#import "TopCell.h"
#import "NetManager.h"


@interface ViewController ()
@property (nonatomic) NSMutableArray<MJData *> *dataList;
//每次的请求返回值
@property (nonatomic) MJRootClass *top;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.tableView registerClass:[TopCell class] forCellReuseIdentifier:@"TopCell"];
    self.title = @"今日头条";
    self.tableView.rowHeight = 80;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [NetManager getTopNews:1034 completionHandler:^(MJRootClass *model, NSError *error) {
            [self.tableView.mj_header endRefreshing];
            if (!error) {
                self.top = model;
                
                [self.dataList removeAllObjects];
                [self.dataList addObjectsFromArray:model.data];
                
                [self.tableView reloadData];
                if (self.top.totalPage == self.top.pageNum) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [self.tableView.mj_footer resetNoMoreData];
                }
            }
        }];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [NetManager getTopNews:self.top.pageNum + 1 completionHandler:^(MJRootClass *model, NSError *error) {
            [self.tableView.mj_footer endRefreshing];
            if (!error) {
                self.top = model;
                [self.dataList addObjectsFromArray:model.data];
                [self.tableView reloadData];
                
                if (self.top.totalPage == self.top.pageNum) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    TopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCell" forIndexPath:indexPath];
    MJData *model = [self.dataList objectAtIndex:indexPath.row];
    [cell.iconIV sd_setImageWithURL:model.photo.yx_URL];
    cell.titleLb.text = model.title;
    cell.detailLb.text = model.content;
    cell.replyLb.text = [@"阅读 " stringByAppendingString:model.readCount];
    cell.dateLb.text = model.time.yx_dateFormat;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSMutableArray<MJData *> *)dataList {
    if(_dataList == nil) {
        _dataList = [[NSMutableArray<MJData *> alloc] init];
    }
    return _dataList;
}

@end
