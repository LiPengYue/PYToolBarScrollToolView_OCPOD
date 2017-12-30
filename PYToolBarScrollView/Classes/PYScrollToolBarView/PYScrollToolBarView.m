//
//  PYScrollToolBarView.m
//  PYToolBarView
//
//  Created by HXB on 2017/4/24.
//  Copyright © 2017年 liPengYue. All rights reserved.
//

#import "PYScrollToolBarView.h"
#import "PYToolBarView.h"
#import "PYMidView.h"
#import "UIView+PYSizeView.h"
//#define kToolBarViewOffsetTop CGPointMake(0, self.kTopViewH + self.scrollTopMargin)
#define kToolBarViewOffsetBottom CGPointMake(0, 0)

@interface PYScrollToolBarView () <UIScrollViewDelegate>


//MARK: 常用的距离参考字段，在layoutSubView里面进行了赋值
@property (nonatomic,assign) BOOL isConstantChange;//是否进行下面的参考距离的计算
@property (nonatomic,assign) CGFloat kScrollToolBarViewW;//self.Width
@property (nonatomic,assign) CGFloat kScrollToolBarViewH;//self.height
@property (nonatomic,assign) CGFloat kTopViewH;//self.topView.height
@property (nonatomic,assign) CGFloat kMidToolBarViewW;//self.midToolBarView.width
@property (nonatomic,assign) CGFloat kMidToolBarViewH;
@property (nonatomic,assign) CGFloat kBottomScrollViewH;//self.BottomScrollView.height
@property (nonatomic,assign) CGFloat kBottomScrollViewY;//self.bottomScrollView.Y
@property (nonatomic,assign) BOOL isSetupSubView;//是否布局子控件
@property (nonatomic,assign) CGFloat offsetY;//当前的scrollView 与self的偏移量的差值
@property (nonatomic,weak) UIScrollView *crruntScrollView;
//MARK: subView
@property (nonatomic,strong) UIView *topView;///顶部的展示view
@property (nonatomic,strong) PYMidView *midView;
@property (nonatomic,strong) PYToolBarView *midToolBarView;///中间的工具栏
@property (nonatomic,strong) UIView *midBackgroundView;
//底部的scrollView，里面装了从外面传进来的view的集合
@property (nonatomic,strong) UIScrollView *bottomScrollView;
@property (nonatomic,assign) BOOL isTouched;

//MARK: 事件传递的block
@property (nonatomic,copy) void(^clickMidToolBarViewBlock)(NSInteger index, NSString *title,UIButton *option);
/// self 滑动的时候调用
@property (nonatomic,copy) void(^scrollCallBack)(CGFloat contentOffsetY);
/// 设置 监听 滚动 的view
@property (nonatomic,copy) UIScrollView *(^setObserveViewScrollBlock)(UIView *currentView,NSInteger index);
@property (nonatomic,strong) NSMutableDictionary *scrollViewDic;
@property (nonatomic,assign) BOOL isScrollBottomView1;
@end



@implementation PYScrollToolBarView


@synthesize bottomViewSet = _bottomViewSet;

#pragma mark - getter
- (UIScrollView *) bottomScrollView {
    if (!_bottomScrollView) {
        _bottomScrollView = [[UIScrollView alloc]init];
    }
    return _bottomScrollView;
}
- (NSArray *)bottomViewSet {
    if (!_bottomViewSet) {
        _bottomViewSet = [[NSArray alloc]init];
    }
    return _bottomViewSet;
}
- (BOOL) isLinkageTopBottomView {
    return false;
}
- (BOOL) isLayoutContentSize {
    return true;
}
#pragma mark - setter
- (void)setBottomViewSet:(NSArray<UIView *> *)bottomViewSet {
    _bottomViewSet = bottomViewSet;
    self.isSetupSubView = true;
    self.isConstantChange = true;
}
- (void)setSelectToolBarViewIndex:(NSInteger)selectToolBarViewIndex {
    _selectToolBarViewIndex = selectToolBarViewIndex;
    self.midToolBarView.selectItemIndex = selectToolBarViewIndex;
}

#pragma mark - 回调事件的传递
///对于中间的ToolBarView点击事件的回调
- (void)midToolBarViewClickWithBlock: (void(^)(NSInteger index, NSString *title,UIButton *option))clickMidToolBarViewBlock {
    self.clickMidToolBarViewBlock = clickMidToolBarViewBlock;
}

#pragma mark - 构造方法
+ (instancetype) scrollToolBarViewWithFrame:(CGRect)frame
                                 andTopView:(UIView *)topView
                                andTopViewH:(CGFloat)topViewH
                          andMidToolBarView:(PYToolBarView *)midToolBarView
                    andMidToolBarViewMargin:(CGFloat)midToolBarViewMargin
                         andMidToolBarViewH:(CGFloat)midToolBarViewH
                           andBottomViewSet:(NSArray <UIView *>*)bottomViewSet
{
    return [[self alloc]initWithFrame:frame andTopView:topView andTopViewH: topViewH andMidToolBarView:midToolBarView andMidToolBarViewMargin:midToolBarViewMargin  andMidToolBarViewH:midToolBarViewH andBottomViewSet:bottomViewSet];
}
- (instancetype) initWithFrame:(CGRect)frame
                    andTopView:(UIView *)topView
                   andTopViewH:(CGFloat)topViewH
             andMidToolBarView:(PYToolBarView *)midToolBarView
       andMidToolBarViewMargin:(CGFloat)midToolBarViewMargin
            andMidToolBarViewH:(CGFloat)midToolBarViewH
              andBottomViewSet:(NSArray <UIView *>*)bottomViewSet
{
    if (self = [super initWithFrame:frame]) {
        self.topView = topView;
        self.kTopViewH = topViewH;
        self.midToolBarViewMargin = midToolBarViewMargin;
        self.midToolBarView = midToolBarView;
        self.kMidToolBarViewH = midToolBarViewH;
        self.bottomViewSet = bottomViewSet;
        self.isConstantChange = true;
        self.isSetupSubView = true;
        self.delegate = self;
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
                    andTopView:(UIView *)topView
                   andTopViewH:(CGFloat)topViewH
                    andMidView:(PYMidView *)midView
       andMidToolBarViewMargin:(CGFloat)midToolBarViewMargin
            andMidToolBarViewH:(CGFloat)midToolBarViewH
              andBottomViewSet:(NSArray<UIView *> *)bottomViewSet {
    if (self = [super initWithFrame:frame]) {
        self.topView = topView;
        self.kTopViewH = topViewH;
        self.midToolBarViewMargin = midToolBarViewMargin;
        self.midView = midView;
        self.midToolBarView = [midView.delegate registerToolBarView];
        self.kMidToolBarViewH = midToolBarViewH;
        self.bottomViewSet = bottomViewSet;
        self.isConstantChange = true;
        self.isSetupSubView = true;
        self.delegate = self;
    }
    return self;
}

#pragma mark - layoutSubViews 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    //常用变量的计算
    [self calculateValue];
    //布局子控件
    [self setupSubViewWithISSetupSubView:self.isSetupSubView];
}

//根据self.isConstantChange，判断是否进行常用变量的计算
- (void)calculateValue {
    if (self.isConstantChange) {
        self.isConstantChange = false;
        self.contentSize = CGSizeMake(0, self.kTopViewH + self.kScrollToolBarViewH + self.frame.size.height);
        self.contentOffset = CGPointMake(0, 0);
        self.kScrollToolBarViewH = self.frame.size.height;
        self.kScrollToolBarViewW = self.frame.size.width;
        self.kMidToolBarViewW = self.kScrollToolBarViewW - self.midToolBarViewMargin * 2;
//        self.kBottomScrollViewH = self.kScrollToolBarViewH - self.kMidToolBarViewH;
        self.kBottomScrollViewH = self.kScrollToolBarViewH;
//        self.kBottomScrollViewY = self.kTopViewH + self.kMidToolBarViewH;
        self.kBottomScrollViewY = 0;
        self.selectToolBarViewIndex = self.midToolBarView.selectItemIndex;
    }
}

//布局子控件
- (void)setupSubViewWithISSetupSubView: (BOOL)isSetupSubView {
    if (!isSetupSubView) {
        return;
    }
    self.contentSize = CGSizeMake(0, self.kTopViewH + self.scrollTopMargin + self.getH);
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
    } else {
        // Fallback on earlier versions
    }
    self.isSetupSubView = NO;
    //布局底部的ScrollView （把外界传入的View集合，添加到scrollView上）
    [self setupBottomScrollView];
    //布局topView
    [self setupTopView];
    //布局midToolBarView
    [self setupMidToolBarView];
    
}

//布局topView
- (void)setupTopView {
    [self addSubview:self.topView];
    self.topView.frame = CGRectMake(0, 0, self.kScrollToolBarViewW, self.kTopViewH);
}

//布局中间的toolBarView
- (void)setupMidToolBarView {
    self.midBackgroundView.frame = CGRectMake(self.midToolBarViewMargin, self.kTopViewH, self.kMidToolBarViewW, self.kMidToolBarViewH);
    [self addSubview:self.midBackgroundView];
//    self.midToolBarView.frame = CGRectMake(self.midToolBarViewMargin, self.kTopViewH, self.kMidToolBarViewW, self.kMidToolBarViewH);
    
    //MARK: 中间的toolbarView点击事件的回调
    __weak typeof (self)weakSelf = self;
    [self.midToolBarView clickOptionItemBLockFuncWithClickOptionItemBlock:^(UIButton *button, NSString *itemText, NSInteger index) {
        CGFloat contentOffsetX = index * weakSelf.kScrollToolBarViewW;
        weakSelf.bottomScrollView.contentOffset = CGPointMake(contentOffsetX, 0);
        //如果点击事件回调被实现，那么执行外部的回调事件
        if (weakSelf.clickMidToolBarViewBlock) weakSelf.clickMidToolBarViewBlock(index,itemText,button);
    }];
    UIView *view = self.midView;
    if (!view) {
        view = self.midToolBarView;
    }
    
    view.frame = CGRectMake(0, 0, self.midBackgroundView.getW, self.midBackgroundView.getH);
    
    if (view == self.midToolBarView) {
        [self.midToolBarView show];
    }
    if (!view) NSLog(@"🌶，没有接收到toolBarView");
    [self.midBackgroundView addSubview: view];
}

//布局底部的ScrollView （把外界传入的View集合，添加到scrollView上）
- (void)setupBottomScrollView {
    self.bottomScrollView = [[UIScrollView alloc]init];
    if (@available(iOS 11.0, *)) {
        self.bottomScrollView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
    } else {
        // Fallback on earlier versions
    }
    self.bottomScrollView.frame = CGRectMake(0, self.kBottomScrollViewY, self.kScrollToolBarViewW, self.kBottomScrollViewH);
    CGFloat bottomScrollViewContentSizeX = self.bottomViewSet.count * self.kScrollToolBarViewW;
    self.bottomScrollView.contentSize = CGSizeMake(bottomScrollViewContentSizeX, self.kBottomScrollViewH);
    self.bottomScrollView.delegate = self;
    self.bottomScrollView.pagingEnabled = true;
    self.bottomScrollView.showsVerticalScrollIndicator = false;
    self.bottomScrollView.showsHorizontalScrollIndicator = false;
    self.contentOffset = CGPointMake(self.midToolBarView.selectItemIndex * self.kScrollToolBarViewW, 0);
    [self addSubview: self.bottomScrollView];
    
    //布局bottomScrollView内部的Views
    [self setupScrollContentSubViews];
}

//布局bottomScrollView内部的Views
- (void)setupScrollContentSubViews {
    __weak typeof (self)weakSelf = self;
    [self.bottomViewSet enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.frame = CGRectMake(idx * weakSelf.kScrollToolBarViewW, 0, weakSelf.kScrollToolBarViewW,weakSelf.kBottomScrollViewH);
        [weakSelf.bottomScrollView addSubview:view];
        //调用
        
        if (weakSelf.setObserveViewScrollBlock) {
            UIScrollView *scrollView = weakSelf.setObserveViewScrollBlock(view,idx);
            if (scrollView) {
                NSString *indexStr = [NSString stringWithFormat:@"%ld",idx];
                view = scrollView;
                weakSelf.scrollViewDic[indexStr] = view;
            }else{
                NSLog(@"\n👌👌👌:\n\n setObserveViewScrollFunc 返回的view为nil, \n     👌massage: \n     👌view为:%@,\n     👌下标为%ld\n👌👌👌",view,idx);
            }
        }
        
        //如果是UIScrollView并且topView有高度的话就监听一下他的contentOffset
        if ([view isKindOfClass:NSClassFromString(@"UIScrollView")] && weakSelf.kTopViewH) {
            UIScrollView *scrollView = (UIScrollView *)view;
            //添加观察者
            [scrollView addObserver:weakSelf forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            if (@available(iOS 11.0, *)) {
                scrollView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
            } else {
                // Fallback on earlier versions
            }
            scrollView.contentInset = UIEdgeInsetsMake(self.kTopViewH + self.kMidToolBarViewH + self.scrollTopMargin, 0, 0, 0);
            scrollView.contentOffset = CGPointMake(0, -_kTopViewH - self.scrollTopMargin - self.kMidToolBarViewH);
            
            ///手势优先级
            [self.panGestureRecognizer requireGestureRecognizerToFail:scrollView.panGestureRecognizer];
        }
    }];
}


//观察者的回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    ///手势监听
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (self.kTopViewH <= 0 || !self.isTouched) {
            return;
        }
        
        UIScrollView *scrollView = (UIScrollView *) object;
        NSNumber *newContentOffsetNum = [change valueForKey:NSKeyValueChangeNewKey];
        CGPoint newContentOffset = newContentOffsetNum.CGPointValue;
        NSNumber *oldNum = [change valueForKey:NSKeyValueChangeOldKey];
        CGPoint oldContentOffset = newContentOffsetNum.CGPointValue;
        //偏移量设置
        [self setScrollContentInset:scrollView];
        
        //是否移动到顶了
        BOOL scrollTop = scrollView.contentOffset.y >= -self.kMidToolBarViewH - self.scrollTopMargin - self.contentOffset.y;
        BOOL scrollBottom = scrollView.contentOffset.y < -self.kTopViewH - self.kMidToolBarViewH;
        
        if (!scrollTop && !scrollBottom) {
            [self.topView setY:-newContentOffset.y - scrollView.contentInset.top];
            [self.midBackgroundView setY: -newContentOffset.y - scrollView.contentInset.top + self.kTopViewH + self.scrollTopMargin];
        }
        
        if (scrollTop) {
            [self.topView setY:-self.kTopViewH + self.contentOffset.y];
            [self.midBackgroundView setY:self.contentOffset.y];
        }
        if (self.contentOffset.y != 0) {
            
        }
        if (scrollBottom) {
            [self setContentOffset:CGPointMake(0, 0) animated:false];
            [self.topView setY:0];
            [self.midBackgroundView setY:self.kTopViewH + self.scrollTopMargin];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self) {
        if (self.contentOffset.y > self.kTopViewH + self.scrollTopMargin) {
            if (self.crruntScrollView) {
                [self.crruntScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
            }
            self.contentOffset = CGPointMake(0,self.kTopViewH + self.scrollTopMargin);
        }
        if (self.contentOffset.y < 0) {
            self.contentOffset = CGPointMake(0, 0);
        }
        
        UIScrollView *currentView = [self crruntScrollView];
        if (currentView) {
            CGRect frame = CGRectMake(currentView.getX, 0, currentView.getW, self.kBottomScrollViewH + self.contentOffset.y);
            self.bottomScrollView.frame = CGRectMake(0, 0, currentView.getW, self.kBottomScrollViewH + self.contentOffset.y);
            
            currentView.frame = frame;
            [currentView setContentOffset:currentView.contentOffset animated:false];
        }
    }
    
    if (scrollView == self.bottomScrollView) {
        //当前滑动的进度
        CGFloat indexFloat = scrollView.contentOffset.x / self.bottomScrollView.getW;
        // 手势拖动的index
        NSInteger frontIndex = self.midToolBarView.selectItemIndex;
        //底部的scrollView的数量
        NSInteger bottomViewCount = self.bottomViewSet.count;
        
        //判断是否越界
        if (indexFloat > frontIndex) {
            NSInteger wellIndex = frontIndex + 1;
            //表示 index ++ 趋势
            if (wellIndex >= bottomViewCount) {
                return;
            }
            [self setWellScrollViewOffset:wellIndex and:frontIndex];
        }else{
            //表示 index -- 趋势
            NSInteger wellIndex = frontIndex - 1;
            if (wellIndex < 0) {
                return;
            }
            [self setWellScrollViewOffset:wellIndex and:frontIndex];
        }
        
        
        //计算偏移量，并且给midToolBarView的selectIndex赋值
        NSInteger index = round(scrollView.contentOffset.x / self.kScrollToolBarViewW);
        if (index != self.midToolBarView.selectItemIndex) {
            //如果越界了，就直接return
            if (index < 0 || index >= self.bottomViewSet.count) return;
            //直接赋值
            self.midToolBarView.selectItemIndex = index;
            //如果点击事件回调被实现，那么执行外部的回调事件
            if (self.clickMidToolBarViewBlock) {
                UIButton *option = self.midToolBarView.optionItemInfo[index];
                NSString *title = self.midToolBarView.optionStrArray[index];
                self.clickMidToolBarViewBlock(index, title, option);
            }
        }
    }
}

- (void)scrollViewCallBackFunc:(void (^)(CGFloat))scrollCallBack {
    self.scrollCallBack = scrollCallBack;
}

- (void)setObserveViewScrollFunc:(UIScrollView * (^)(UIView *, NSInteger))setObserveViewScrollBlock {
    self.setObserveViewScrollBlock = setObserveViewScrollBlock;
}
- (void)dealloc{
    //销毁观察者：
    [self.bottomViewSet enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass: [UIScrollView class]]) {
            [obj removeObserver:self forKeyPath:@"contentOffset"];
        }
    }];
    NSLog(@"✅ %@ 被销毁",NSStringFromClass(self.class));
}

///设置 contentInset
- (void) setScrollContentInset:(UIScrollView *)scrollView {
    
    CGFloat insertTop = scrollView.contentInset.top;
    
    if (scrollView.contentSize.height <= scrollView.getH + self.kTopViewH - self.scrollTopMargin - self.contentOffset.y) {
        CGFloat insertY = scrollView.getH - scrollView.contentSize.height - self.contentOffset.y - self.kMidToolBarViewH;
        insertY = (insertY < 0) ? 0 : insertY;
        scrollView.contentInset = UIEdgeInsetsMake(insertTop, 0, insertY, 0);
    }else{
        scrollView.contentInset = UIEdgeInsetsMake(insertTop, 0, 0, 0);
    }
}

///平衡scrollViewoffset
- (void) setWellScrollViewOffset:(NSInteger)wellIndex and:(NSInteger)frontIndex {
    UIScrollView *wellScrollView = [self getBottomScrollView:wellIndex];
    UIScrollView *currentScrollView = [self getBottomScrollView:frontIndex];
    if (wellScrollView) {
        if (currentScrollView) {
            CGFloat offsetY = (currentScrollView.contentOffset.y >= -self.kMidToolBarViewH - self.scrollTopMargin) ? -self.kMidToolBarViewH - self.scrollTopMargin : currentScrollView.contentOffset.y + self.contentOffset.y;
            offsetY = (offsetY <= -self.kTopViewH - self.scrollTopMargin - self.kMidToolBarViewH) ? -self.kTopViewH - self.scrollTopMargin - self.kMidToolBarViewH : self.contentOffset.y;
            wellScrollView.frame = CGRectMake(wellScrollView.getX, currentScrollView.getY, wellScrollView.getW, currentScrollView.getH);
            [wellScrollView setContentOffset:CGPointMake(0, offsetY) animated:false];
        }
    }
}
- (UIScrollView *)getBottomScrollView: (NSInteger) index {
    UIView *view = self.bottomViewSet[index];
    if ([view isKindOfClass:UIScrollView.class]) {
        return view;
    }
    return nil;
}
- (UIScrollView *)crruntScrollView {
    NSInteger index = self.midToolBarView.selectItemIndex;
    NSString *indexStr = [NSString stringWithFormat:@"%ld",index];
    if (self.scrollViewDic[indexStr]) {
        return self.scrollViewDic[indexStr];
    }else{
        UIScrollView *scrollView = (UIScrollView *)self.bottomViewSet[index];
        return scrollView;
    }
    return nil;
}
- (NSMutableDictionary *)scrollViewDic {
    if(!_scrollViewDic) {
        _scrollViewDic = [[NSMutableDictionary alloc]init];
    }
    return _scrollViewDic;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    self.isTouched = true;
    return [super hitTest:point withEvent:event];
}

- (UIView *)midBackgroundView {
    if(!_midBackgroundView) {
         _midBackgroundView = [[UIView alloc]init];
    }
    return _midBackgroundView;
}
@end




