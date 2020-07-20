//
//  DAlertView.h
//  DProgressHUD
//
//  Created by wudan on 2020/7/20.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DAlertViewAniamtion) {
    DAlertViewAniamtionScale = 0, ///<  默认
    DAlertViewAniamtionRatationAndScale,
    DAlertViewAniamtionFromBottom,
    DAlertViewAniamtionFromRight,
    DAlertViewAniamtionFromLeft
};

/**
    广告弹窗视图
    用于承载显示View，支持多种动画效果。
 */

@interface DAlertView : UIView
+ (void)showView:(UIView *)view;
+ (void)showView:(UIView *)view aniamtion:(DAlertViewAniamtion)animation;
+ (void)showView:(UIView *)view aniamtion:(DAlertViewAniamtion)animation duration:(NSTimeInterval)duration;

+ (void)dimiss;
@end

NS_ASSUME_NONNULL_END
