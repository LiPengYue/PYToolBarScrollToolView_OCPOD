//
//  UIView+PYSizeView.m
//  FBSnapshotTestCase
//
//  Created by 李鹏跃 on 2017/12/30.
//

#import "UIView+PYSizeView.h"

@implementation UIView (PYSizeView)
- (CGFloat)getY {
    return self.frame.origin.y;
}
- (CGFloat)getX {
    return self.frame.origin.x;
}
- (CGFloat)getH {
    return self.frame.size.height;
}
- (CGFloat)getW {
    return self.frame.size.width;
}

- (void) addH: (CGFloat)H {
    self.frame = CGRectMake(self.getX, self.getY, self.getW, self.getH + H);
}
- (void) setH: (CGFloat)H {
    self.frame = CGRectMake(self.getX, self.getY, self.getW, H);
}
- (void) setY: (CGFloat)Y {
    self.frame = CGRectMake(self.getX, Y, self.getW, self.getH);
}
- (void) addY: (CGFloat)Y {
    self.frame = CGRectMake(self.getX,self.getY + Y, self.getW, self.getH);
}
@end
