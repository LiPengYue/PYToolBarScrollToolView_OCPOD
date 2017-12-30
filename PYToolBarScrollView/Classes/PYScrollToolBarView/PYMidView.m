//
//  PYMidView.m
//  FBSnapshotTestCase
//
//  Created by 李鹏跃 on 2017/12/30.
//

#import "PYMidView.h"
#import "PYToolBarView.h"
@interface PYMidView()
@property (nonatomic,assign) BOOL isFirstSetToolBarUI;
@end
@implementation PYMidView {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.delegate = self;
    self.isFirstSetToolBarUI = true;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isFirstResponder) {
        
        self.isFirstSetToolBarUI = false;
        if ([self.delegate respondsToSelector:@selector(registerToolBarView)]) {
            [[self.delegate registerToolBarView] show];
            [self layoutIfNeeded];
            return;
        }
        NSLog(@"找不到您的toolBarView，请检查");
    }
}

- (PYToolBarView *)registerToolBarView {
    return nil;
}
@end
