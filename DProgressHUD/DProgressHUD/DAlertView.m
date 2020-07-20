//
//  DAlertView.m
//  DProgressHUD
//
//  Created by wudan on 2020/7/20.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "DAlertView.h"

@interface DAlertView ()
@property (nonatomic, strong) UIButton *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) DAlertViewAniamtion animation;
@property (nonatomic, assign) NSTimeInterval duration;
@end

@implementation DAlertView

+ (instancetype)shard {
    static dispatch_once_t onceToken;
    static DAlertView *alter;
    dispatch_once(&onceToken, ^{
        alter = [[self alloc] init];
    });
    return alter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [[UIScreen mainScreen] bounds];
    }
    return self;
}

#pragma mark - Public Method

+ (void)showView:(UIView *)view {
    [self showView:view aniamtion:DAlertViewAniamtionScale];
}

+ (void)showView:(UIView *)view aniamtion:(DAlertViewAniamtion)animation {
    [self showView:view aniamtion:animation duration:0.25];
}

+ (void)showView:(UIView *)view aniamtion:(DAlertViewAniamtion)animation duration:(NSTimeInterval)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DAlertView shard] showView:view aniamtion:animation duration:duration];
    });
}

+ (void)dimiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DAlertView shard] hidenView];
    });
}

#pragma mark - Private Method
- (void)showView:(UIView *)view aniamtion:(DAlertViewAniamtion)animation duration:(NSTimeInterval)duration {
    self.animation = animation;
    self.duration = duration;
    [self setupBackgroundView];
    [self setupContainerView];
    [self setupSizeWithView:view];
    [self setupPosition];
}

- (void)hidenView {
    
    if (self.animation == DAlertViewAniamtionScale) {
       [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        } completion:^(BOOL finished) {
            [self removeAllViews];
        }];
    } else if (self.animation == DAlertViewAniamtionRatationAndScale) {
        
        CGAffineTransform transform = CGAffineTransformMakeScale(0.01, 0.01);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = transform;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        } completion:^(BOOL finished) {
            [self removeAllViews];
        }];
    } else if (self.animation == DAlertViewAniamtionFromBottom) {
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.frame.size.height);;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:^(BOOL finished) {
            [self removeAllViews];
        }];
    } else if (self.animation == DAlertViewAniamtionFromRight) {
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformMake(1, 0, 0, 1, -UIScreen.mainScreen.bounds.size.width, 0);
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:^(BOOL finished) {
            [self removeAllViews];
        }];
    } else {
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformMake(1, 0, 0, 1, UIScreen.mainScreen.bounds.size.width, 0);
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:^(BOOL finished) {
            [self removeAllViews];
        }];
    }
}

- (void)removeAllViews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self.backgroundView removeFromSuperview]; self.backgroundView = nil;
    [self.containerView removeFromSuperview]; self.containerView = nil;
}

- (void)setupBackgroundView {
    if (self.backgroundView == nil) {
        UIWindow *window = [[UIApplication sharedApplication] windows].firstObject;
        self.backgroundView = [[UIButton alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.backgroundView addTarget:self action:@selector(hidenView) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:self.backgroundView];
    }
}

- (void)setupContainerView {
    if (self.containerView == nil) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.backgroundView addSubview:self.containerView];
    }
}

- (void)setupSizeWithView:(UIView *)view {
    CGRect showRect = CGRectZero;
    if (view.frame.size.width > [[UIScreen mainScreen] bounds].size.width) {
        showRect.size.width = [[UIScreen mainScreen] bounds].size.width - 25 * 2;
    } else {
        showRect.size.width = CGRectGetWidth(view.frame);
    }
    
    if (view.frame.size.height > [[UIScreen mainScreen] bounds].size.height) {
        showRect.size.height = [[UIScreen mainScreen] bounds].size.height;
    } else {
        showRect.size.height = CGRectGetHeight(view.frame);
    }

    showRect.origin.x = ([UIScreen mainScreen].bounds.size.width - showRect.size.width) / 2;
    showRect.origin.y = ([UIScreen mainScreen].bounds.size.height - showRect.size.height) / 2;
    self.containerView.frame = showRect;
    view.frame = self.containerView.bounds;
    if (view.superview == nil) {
        [self.containerView addSubview:view];
    }
}

- (void)setupPosition {
    
    if (self.animation == DAlertViewAniamtionScale) {
        self.containerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:nil];
    } else if (self.animation == DAlertViewAniamtionRatationAndScale) {
        CGAffineTransform transform = CGAffineTransformMakeScale(0.5, 0.5);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        self.containerView.transform = transform;
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:nil];
    } else if (self.animation == DAlertViewAniamtionFromBottom) {
        self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.frame.size.height);
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:nil];
    } else if (self.animation == DAlertViewAniamtionFromLeft) {
        self.containerView.transform = CGAffineTransformMake(1, 0, 0, 1, -UIScreen.mainScreen.bounds.size.width, 0);
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:nil];
    } else if (self.animation == DAlertViewAniamtionFromRight) {
        self.containerView.transform = CGAffineTransformMake(1, 0, 0, 1, UIScreen.mainScreen.bounds.size.width, 0);
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        } completion:nil];
    }
}
@end
