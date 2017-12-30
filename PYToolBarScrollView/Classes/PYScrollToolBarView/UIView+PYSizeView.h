//
//  UIView+PYSizeView.h
//  FBSnapshotTestCase
//
//  Created by 李鹏跃 on 2017/12/30.
//

#import <UIKit/UIKit.h>

@interface UIView (PYSizeView)
- (CGFloat) getX;
- (CGFloat) getY;
- (CGFloat) getH;
- (CGFloat) getW;
- (void) addH: (CGFloat)H;
- (void) setH: (CGFloat)H;
- (void) addY: (CGFloat)Y;
- (void) setY: (CGFloat)Y;
@end
