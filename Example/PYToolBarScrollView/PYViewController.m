//
//  PYViewController.m
//  PYToolBarScrollView
//
//  Created by LiPengYue on 12/14/2017.
//  Copyright (c) 2017 LiPengYue. All rights reserved.
//

#import "PYViewController.h"
#import <PYToolBarScrollView/PYScrollToolBarView.h>
#import <PYToolBarScrollView/PYToolBarView.h>
#import "PYTableView.h"
#import "PYCollectionView.h"

@interface PYViewController ()
    @property (nonatomic,strong) PYScrollToolBarView *scrollToolBarView;
@property (nonatomic,strong) UIImageView *topView;
@property (nonatomic,strong) PYToolBarView *toolBarView;
@end

@implementation PYViewController

- (void)viewDidLoad
{
    [self setUP];
}

- (void)setUP {
    NSArray <UIScrollView *>* array = [self getViewArray];
    self.scrollToolBarView = [[PYScrollToolBarView alloc]initWithFrame:self.view.frame andTopView:self.topView andTopViewH:self.view.frame.size.height andMidToolBarView:self.toolBarView andMidToolBarViewMargin:0 andMidToolBarViewH:40 andBottomViewSet:array];
    self.scrollToolBarView.scrollTopMargin = 64;
    [self.view addSubview: self.scrollToolBarView];
}


- (PYToolBarView *) toolBarView {
    if(!_toolBarView) {
        _toolBarView = [[PYToolBarView alloc]initWithFrame:CGRectZero andOptionStrArray:@[@"我",@"是"]];
    }
    return _toolBarView;
}

- (UIImageView *) topView {
    if (!_topView) {
        _topView = [UIImageView new];
        _topView.image = [UIImage imageNamed:@"2"];
    }
    return _topView;
}

- (NSArray <UIScrollView *>*)getViewArray {
    UIScrollView *tableView = [[PYTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    UIScrollView *collectionView = [[PYCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    return @[tableView,collectionView];
}
@end
