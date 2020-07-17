//
//  DProgressHUD.h
//  DProgressHUD
//
//  Created by wudan on 2020/7/16.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DProgressHUDAnimationType) {
    DProgressHUDAnimationNone,                       ///< 不显示动画
    DProgressHUDAnimationSystemActivityIndicator,    ///< 系统菊花
    DProgressHUDAnimationHorizontalCirclesPulse,     ///< 水平三个圈，尺寸与透明度变换
    DProgressHUDAnimationCircleSpinFade,             ///<  八个元围绕为一圈，尺寸与透明度变换
    DProgressHUDAnimationLineScaling,                ///< 音浪
    DProgressHUDAnimationLineSpinFade,               ///< 自定义菊花
    DProgressHUDAnimationCircleRotateChase,          ///< 五个点追随
    DProgressHUDAnimationCircleStrokeSpin,           ///< 仿安卓转圈
    DProgressHUDAnimationprogress,                   ///<  环形进度
    DProgressHUDAnimationSuccess,                    ///< 成功
    DProgressHUDAnimationFailed                      ///< 失败
};


@interface DProgressHUD : UIView

#pragma mark - Class Property
/**
    单例创建
    1.  属性为类属性，显示弹窗前进行配置，调用方式 eg: ` DProgressHUD.colorHUD = [UIColor darkGrayColor];  // 设置弹窗容器的背景颜色`
    2.  除显示进度弹窗外，弹窗时都是可以进行用户操作
    3.  弹窗会显示后，会自动消失的有 ` showImage `, ` showSuccess `, ` showFailed `, `showText`， 其余需要手动控制消失
 */
@property (nonatomic, assign, class) DProgressHUDAnimationType animationType;
/** 用户不可以点击，窗口背景颜色，默认为黑色，透明度为0.1 */
@property (nonatomic, strong, class) UIColor *colorBackground;
/** 弹窗背景颜色，默认为[UIColor grayColor]*/
@property (nonatomic, strong, class) UIColor *colorHUD;
/** 文本颜色，默认为[UIColor whiteColor]*/
@property (nonatomic, strong, class) UIColor *colorStatus;
/** 动画线条颜色，默认为[UIColor whiteColor]*/
@property (nonatomic, strong, class) UIColor *colorAnimation;
/** 进度条颜色，默认为[UIColor whiteColor]*/
@property (nonatomic, strong, class) UIColor *colorProgress;
/** 文本字体，默认为[UIFont boldSystemFontOfSize:24]*/
@property (nonatomic, strong, class) UIFont *fontStatus;

+ (void)showText:(NSString *)text;

+ (void)show;
+ (void)showWithStatus:(NSString *)status;

+ (void)showSuccess;
+ (void)showSuccessWithStatus:(NSString *)status;

+ (void)showFailed;
+ (void)showFailedWithStatus:(NSString *)status;

+ (void)showAnimateType:(DProgressHUDAnimationType)animationType;
+ (void)showAnimateType:(DProgressHUDAnimationType)animationType status:(NSString *)status;
+ (void)showAnimateType:(DProgressHUDAnimationType)animationType status:(NSString *)status interaction:(BOOL)interaction;

+ (void)showProgress:(CGFloat)progress;
+ (void)showProgress:(CGFloat)progress status:(NSString *)status;
+ (void)showProgress:(CGFloat)progress interaction:(BOOL)interaction;
+ (void)showProgress:(CGFloat)progress status:(NSString *)status interaction:(BOOL)interaction;

+ (void)showImage:(UIImage *)image;
+ (void)showImage:(UIImage *)image status:(NSString *)status;
+ (void)showImage:(UIImage *)image interaction:(BOOL)interaction;
+ (void)showImage:(UIImage *)image status:(NSString *)status interaction:(BOOL)interaction;

+ (void)dimiss;
+ (void)dimiss:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
