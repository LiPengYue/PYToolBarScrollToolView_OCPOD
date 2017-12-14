//
//  PYScrollToolBarView.h
//  PYToolBarView
//
//  Created by HXB on 2017/4/24.
//  Copyright © 2017年 liPengYue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PYToolBarView;
@interface PYScrollToolBarView : UIScrollView
///底部的view的集合
@property (nonatomic,strong) NSArray <UIView *>* bottomViewSet;

///中间的工具栏距离self左右两边的距离
@property (nonatomic,assign) CGFloat midToolBarViewMargin;

@property (nonatomic,assign) NSInteger selectToolBarViewIndex;
///顶部 停留间距
@property (nonatomic,assign) CGFloat scrollTopMargin;
///是否可以滚动到顶部,在传入的scrollView,contentSize不够的情况下 暂时关闭 重写了get方法,一直设置为true
@property (nonatomic,assign) BOOL isLayoutContentSize;

///暂时关闭 不支持联动 重写了get方法,一直设置为false
@property (nonatomic,assign) BOOL isLinkageTopBottomView;

+ (instancetype) scrollToolBarViewWithFrame:(CGRect)frame
                                 andTopView:(UIView *)topView
                                andTopViewH:(CGFloat)topViewH
                          andMidToolBarView:(PYToolBarView *)midToolBarView
                    andMidToolBarViewMargin:(CGFloat)midToolBarViewMargin
                         andMidToolBarViewH:(CGFloat)midToolBarViewH
                           andBottomViewSet:(NSArray <UIView *>*)bottomViewSet;

- (instancetype) initWithFrame:(CGRect)frame
                    andTopView:(UIView *)topView
                   andTopViewH:(CGFloat)topViewH
             andMidToolBarView:(PYToolBarView *)midToolBarView
       andMidToolBarViewMargin:(CGFloat)midToolBarViewMargin
            andMidToolBarViewH:(CGFloat)midToolBarViewH
              andBottomViewSet:(NSArray <UIView *>*)bottomViewSet;
///对于中间的ToolBarView点击事件的回调
- (void)midToolBarViewClickWithBlock: (void(^)(NSInteger index, NSString *title,UIButton *option))clickMidToolBarViewBlock;
/// self 滑动的时候调用
- (void)scrollViewCallBackFunc: (void(^)(CGFloat contentOffsetY)) scrollCallBack;

/// 设置 监听 滚动 的view
- (void) setObserveViewScrollFunc: (UIScrollView *(^)(UIView *currentView,NSInteger index))setObserveViewScrollBlock;
@end
