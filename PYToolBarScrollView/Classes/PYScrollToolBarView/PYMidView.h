//
//  PYMidView.h
//  FBSnapshotTestCase
//
//  Created by 李鹏跃 on 2017/12/30.
//

#import <UIKit/UIKit.h>
@class PYToolBarView;
@protocol PYToolBarViewProtocol <NSObject>
/// 获取toolBarView
- (PYToolBarView *) registerToolBarView;
@end

/**中间的toolBarView 自定义
 继承这个类，self.delegate = self,并实现registerToolBarView，返回 toolbarView
 */
@interface PYMidView : UIView <PYToolBarViewProtocol>
///请实现代理方法
@property (nonatomic,weak) id <PYToolBarViewProtocol> delegate;
@end
