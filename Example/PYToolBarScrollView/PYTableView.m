//
//  PYTableView.m
//  PYToolBarScrollView_Example
//
//  Created by 李鹏跃 on 2017/12/30.
//  Copyright © 2017年 LiPengYue. All rights reserved.
//

#import "PYTableView.h"
@interface PYTableView ()  <UITableViewDelegate,UITableViewDataSource>


@end


@implementation PYTableView
static NSString *cellID = @"cellID";
- (instancetype) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self setUP];
    }
    return self;
}

- (void)setUP {
    self.delegate = self;
    self.dataSource = self;
    self.rowHeight = 150;
    [self registerClass: UITableViewCell.class forCellReuseIdentifier:cellID];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    [[cell viewWithTag:100] removeFromSuperview];
   
    UIImage *image = [UIImage imageNamed: @"1"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.tag = 100;
    
    imageView.frame = CGRectMake(0, 0, self.frame.size.width, 150);
    [cell.contentView addSubview:imageView];
    
    return cell;
}


@end


