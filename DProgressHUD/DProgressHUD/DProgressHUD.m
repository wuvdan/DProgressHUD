//
//  DProgressHUD.m
//  DProgressHUD
//
//  Created by wudan on 2020/7/16.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "DProgressHUD.h"

@interface DProgressView : UIView
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) CAShapeLayer *layerCicle;
@property (nonatomic, strong) CAShapeLayer *layerProgress;
@property (nonatomic, strong) UILabel *labelPercentage;
@property (nonatomic, assign) CGFloat progress;

- (void)setProgressWithValue:(CGFloat)value duration:(NSTimeInterval)duration;
@end


@interface DProgressHUD ()
#pragma mark Data
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) DProgressHUDAnimationType animationType;
@property (nonatomic, strong) UIColor *colorBackground;
@property (nonatomic, strong) UIColor *colorHUD;
@property (nonatomic, strong) UIColor *colorStatus;
@property (nonatomic, strong) UIColor *colorAnimation;
@property (nonatomic, strong) UIColor *colorProgress;
@property (nonatomic, strong) UIFont *fontStatus;

#pragma mark UI
@property (nonatomic, strong) UIView *viewBackground;
@property (nonatomic, strong) UIView *toolbarHUD;
@property (nonatomic, strong) UILabel *labelStatus;
@property (nonatomic, strong) UIView *viewAnimation;
@property (nonatomic, strong) DProgressView *viewProgress;
@property (nonatomic, strong) UIImageView *staticImageView;
@end

@interface DProgressHUD (Animation)
- (void)animationCircleRotateChaseWithView:(UIView *)view;
- (void)animationLineSpinFadeWithView:(UIView *)view;
- (void)animationCircleSpinFadeWithView:(UIView *)view;
- (void)animationCircleStrokeSpinWithView:(UIView *)view;
- (void)animationSystemActivityIndicatorWithView:(UIView *)view;
- (void)animationHorizontalCirclesPulseWithView:(UIView *)view;
- (void)animationLineScalingWithView:(UIView *)view;
- (void)animationSuccessWithView:(UIView *)view;
- (void)animationFailedWithView:(UIView *)view;
@end

@implementation DProgressHUD

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static DProgressHUD *hud = nil;
    dispatch_once(&onceToken, ^{
        hud = [[self alloc] init];
    });
    return hud;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [[UIScreen mainScreen] bounds];
        self.colorBackground = [UIColor colorWithWhite:0 alpha:0.1];
        self.colorHUD = [UIColor grayColor];
        self.colorStatus = [UIColor whiteColor];
        self.colorAnimation = [UIColor whiteColor];
        self.colorProgress = [UIColor whiteColor];
        self.fontStatus = [UIFont boldSystemFontOfSize:24];
        self.alpha = 0;
        self.animationType = DProgressHUDAnimationCircleStrokeSpin;
    }
    return self;
}

- (void)setupWithStatus:(NSString *)status
               progress:(CGFloat)progress
            staticImage:(UIImage * _Nullable)staticImage
                  hiden:(BOOL)hiden
            interaction:(BOOL)interaction {

    [self setupNotifications];
    [self setupBackgroundWithInteraction:interaction];
    [self setupToolbar];
    [self setupLabelWithStatus:status];
    
    if (staticImage != nil) {
        [self setupStaticImage:staticImage];
    } else {
        if (self.animationType == DProgressHUDAnimationprogress) {
            [self setupProgress:progress];
        } else {
           [self setupAnimation];
        }
    }
    [self setupSize];
    [self setupPosition:nil];
    
    [self hudShow];
    
    if (hiden) {
        NSString *text = self.labelStatus.text;
        NSTimeInterval delay = text.length * 0.03 + 1.25;
        __weak __typeof(self)weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay repeats:NO block:^(NSTimer * _Nonnull timer) {
            [weakSelf timerComeDown];
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark Timer

- (void)timerComeDown {
    [self hudHiden];
}

- (void)destoryTimer {
    [self.timer invalidate];
    self.timer = nil;
}
#pragma mark - Set up View

- (void)setupAnimation {
    [self.viewProgress removeFromSuperview];
    [self.staticImageView removeFromSuperview];
    
    if (self.viewAnimation == nil) {
        self.viewAnimation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    }
    
    if (self.viewAnimation.superview == nil) {
        [self.toolbarHUD addSubview:self.viewAnimation];
    }
    
    for (UIView *v in self.viewAnimation.subviews) {[v removeFromSuperview];}
    
    while (self.viewAnimation.layer.sublayers.count) {
        CALayer* child = self.viewAnimation.layer.sublayers.lastObject;
       [child removeFromSuperlayer];
    }
        
    switch (self.animationType)
    {
        case DProgressHUDAnimationSystemActivityIndicator:
        {
            [self animationSystemActivityIndicatorWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationCircleStrokeSpin:
        {
            [self animationCircleStrokeSpinWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationHorizontalCirclesPulse:
        {
            [self animationHorizontalCirclesPulseWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationLineScaling:
        {
            [self animationLineScalingWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationCircleSpinFade:
        {
            [self animationCircleSpinFadeWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationLineSpinFade:
        {
            [self animationLineSpinFadeWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationCircleRotateChase:
        {
            [self animationCircleRotateChaseWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationSuccess:
        {
            [self animationSuccessWithView:self.viewAnimation];
        }
            break;
        case DProgressHUDAnimationFailed:
        {
            [self animationFailedWithView:self.viewAnimation];
        }
            break;
        default:
            break;
    }
}

- (void)setupBackgroundWithInteraction:(BOOL)interaction {
    if (self.viewBackground == nil) {
        UIWindow *mainView = [[UIApplication sharedApplication] windows].firstObject;
        self.viewBackground = [[UIView alloc] initWithFrame:self.bounds];
        [mainView addSubview:self.viewBackground];
    }
    self.viewBackground.backgroundColor = interaction ? [UIColor clearColor] : self.colorBackground;
    self.viewBackground.userInteractionEnabled = (interaction == NO);
}

- (void)setupToolbar {
    if (self.toolbarHUD == nil) {
        self.toolbarHUD = [[UIView alloc] initWithFrame:CGRectZero];
        self.toolbarHUD.clipsToBounds = YES;
        self.toolbarHUD.layer.cornerRadius = 10;
        self.toolbarHUD.layer.masksToBounds = YES;
        [self.viewBackground addSubview:self.toolbarHUD];
    }
    self.toolbarHUD.backgroundColor = self.colorHUD;
}

- (void)setupLabelWithStatus:(NSString *)status {
    if (self.labelStatus == nil) {
        self.labelStatus = [[UILabel alloc] init];
        self.labelStatus.textAlignment = NSTextAlignmentCenter;
        self.labelStatus.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.labelStatus.numberOfLines = 0;
        [self.toolbarHUD addSubview:self.labelStatus];
    }

    self.labelStatus.text = status;
    self.labelStatus.font = self.fontStatus;
    self.labelStatus.textColor = self.colorStatus;
    self.labelStatus.hidden = (status.length == 0) ? YES : NO;
}

- (void)setupProgress:(CGFloat)progress {
    [self.viewAnimation removeFromSuperview];
    [self.staticImageView removeFromSuperview];
    
    if (self.viewProgress == nil) {
        self.viewProgress = [[DProgressView alloc] init];
        self.viewProgress.color = self.colorProgress;
        self.viewProgress.frame = CGRectMake(0, 0, 70, 70);
    }
    
    if (self.viewProgress.superview == nil) {
        [self.toolbarHUD addSubview:self.viewProgress];
    }
    [self.viewProgress setProgressWithValue:progress duration:0.2];
}

- (void)setupStaticImage:(UIImage *)staticImage {
    [self.viewAnimation removeFromSuperview];
    [self.staticImageView removeFromSuperview];
    
    if (self.staticImageView == nil) {
        self.staticImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    }
    if (self.staticImageView.superview == nil) {
        [self.toolbarHUD addSubview:self.staticImageView];
    }
    
    self.staticImageView.image = staticImage;
    self.staticImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setupSize {
    CGFloat width = 120;
    CGFloat height = 120;
    
    if (self.animationType == DProgressHUDAnimationNone) {
        CGSize sizeMax = CGSizeMake(250, 250);
        CGRect rectLabel = [self.labelStatus.text boundingRectWithSize:sizeMax options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : self.labelStatus.font} context:nil];
        width = ceil(rectLabel.size.width);
        height = ceil(rectLabel.size.height);
        if (width < 20) { width = 20; }
        if (width > 250) { width = 250; }
        rectLabel.origin.x = 8;
        rectLabel.origin.y = 8;
        self.labelStatus.frame = rectLabel;
        self.toolbarHUD.bounds = CGRectMake(0, 0, width + 16, height + 16);
    } else {
        
        if (self.labelStatus.text.length > 0) {
            CGSize sizeMax = CGSizeMake(250, 250);
            CGRect rectLabel = [self.labelStatus.text boundingRectWithSize:sizeMax options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : self.labelStatus.font} context:nil];
            width = ceil(rectLabel.size.width) + 60;
            height = ceil(rectLabel.size.height) + 120;
            if (width < 120) { width = 120; }
            rectLabel.origin.x = (width - rectLabel.size.width) / 2;
            rectLabel.origin.y = (height - rectLabel.size.height) / 2 + 45;
            self.labelStatus.frame = rectLabel;
        }
        
        self.toolbarHUD.bounds = CGRectMake(0, 0, width, height);
        
        CGFloat centerX = width / 2;
        CGFloat centerY = width / 2;
        
        if (self.labelStatus.text.length > 0) { centerY = 55; };

        self.viewAnimation.center = CGPointMake(centerX, centerY);
        self.viewProgress.center = CGPointMake(centerX, centerY);
        self.staticImageView.center = CGPointMake(centerX, centerY);
    }
}

- (void)setupPosition:(NSNotification * _Nullable)notification {
    CGFloat heightKeyboard = 0;
    NSTimeInterval animationDuration = 0;

    if (notification) {
        CGRect frameKeyboard = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if ([notification.name isEqualToString:UIKeyboardWillShowNotification] || [notification.name isEqualToString:UIKeyboardDidShowNotification]) {
            heightKeyboard = frameKeyboard.size.height;
        } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification] || [notification.name isEqualToString:UIKeyboardDidHideNotification]) {
            heightKeyboard = 0;
        } else {
            heightKeyboard = [self keyboardHeight];
        }
    } else {
        heightKeyboard = [self keyboardHeight];
    }
    
    CGRect screen = UIScreen.mainScreen.bounds;
    CGPoint center = CGPointMake(screen.size.width/2, (screen.size.height-heightKeyboard)/2);
    [UIView animateWithDuration:animationDuration delay:0 options:(UIViewAnimationOptionAllowUserInteraction) animations:^{
        if (self.animationType == DProgressHUDAnimationNone) {
            self.toolbarHUD.center = CGPointMake(center.x, screen.size.height - self.toolbarHUD.frame.size.height - 100 - heightKeyboard);
        } else {
            self.toolbarHUD.center = center;
        }
        self.viewBackground.frame = screen;
    } completion:nil];
}

- (CGFloat)keyboardHeight {
    Class keyboardWindowClass = NSClassFromString(@"UIRemoteKeyboardWindow");
    Class inputSetContainerView = NSClassFromString(@"UIInputSetContainerView");
    Class inputSetHostView = NSClassFromString(@"UIInputSetHostView");
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass: keyboardWindowClass]) {
            for (UIWindow *firstSubView in window.subviews) {
                if ([firstSubView isKindOfClass: inputSetContainerView]) {
                    for (UIWindow *secondSubView in firstSubView.subviews) {
                        if ([secondSubView isKindOfClass: inputSetHostView]){
                            return secondSubView.frame.size.height;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

- (void)hudShow {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.alpha != 1) {
        self.alpha = 1;
        self.toolbarHUD.alpha = 0;
        self.toolbarHUD.transform = CGAffineTransformMakeScale(1.4, 1.4);
        
        [UIView animateWithDuration:0.15 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn) animations:^{
            self.toolbarHUD.transform = CGAffineTransformMakeScale(1 / 1.4, 1 / 1.4);
            self.toolbarHUD.alpha = 1;
        } completion:nil];
    }
}

#pragma mark Notification

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPosition:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPosition:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPosition:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPosition:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPosition:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)hudHiden {
    if (self.alpha == 1) {
        [UIView animateWithDuration:0.15 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn) animations:^{
            self.toolbarHUD.transform = CGAffineTransformMakeScale(0.3, 0.3);
            self.toolbarHUD.alpha = 0;
        } completion:^(BOOL finished) {
            [self hudDestroy];
            self.alpha = 0;
        }];
    }
}

- (void)hudDestroy {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.staticImageView removeFromSuperview];  self.staticImageView = nil;
    [self.viewAnimation   removeFromSuperview];  self.viewAnimation = nil;
    [self.viewProgress    removeFromSuperview];  self.viewProgress = nil;

    [self.labelStatus     removeFromSuperview];  self.labelStatus = nil;
    [self.toolbarHUD      removeFromSuperview];  self.toolbarHUD = nil;
    [self.viewBackground  removeFromSuperview];  self.viewBackground = nil;
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Public Methods
+ (void)dimiss {
    [self dimiss:0];
}

+ (void)dimiss:(NSTimeInterval)duration {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[DProgressHUD shared] hudHiden];
    });
}

+ (void)show {
    [self showAnimateType:DProgressHUDAnimationCircleStrokeSpin status:@"" interaction:YES];
}

+ (void)showWithStatus:(NSString *)status {
    [self showAnimateType:DProgressHUDAnimationCircleStrokeSpin status:status interaction:YES];
}

+ (void)showAnimateType:(DProgressHUDAnimationType)animationType {
    [self showAnimateType:animationType status:@"" interaction:YES];
}

+ (void)showAnimateType:(DProgressHUDAnimationType)animationType status:(NSString *)status {
    [self showAnimateType:animationType status:status interaction:YES];
}

+ (void)showAnimateType:(DProgressHUDAnimationType)animationType status:(NSString *)status interaction:(BOOL)interaction {
    DProgressHUD.animationType = animationType;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DProgressHUD shared] setupWithStatus:status progress:0 staticImage:nil hiden:NO interaction:YES];
    });
}

#pragma mark Status Success && Failed
+ (void)showSuccess {
    [self showSuccessWithStatus:@""];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    DProgressHUD.animationType = DProgressHUDAnimationSuccess;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DProgressHUD shared] setupWithStatus:status progress:0 staticImage:nil hiden:YES interaction:YES];
    });
}

+ (void)showFailed {
    [self showFailedWithStatus:@""];
}

+ (void)showFailedWithStatus:(NSString *)status {
    DProgressHUD.animationType = DProgressHUDAnimationFailed;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DProgressHUD shared] setupWithStatus:status progress:0 staticImage:nil hiden:YES interaction:YES];
    });
}

#pragma mark Progress View
+ (void)showProgress:(CGFloat)progress status:(NSString *)status {
    [self showProgress:progress status:status interaction:NO];
}

+ (void)showProgress:(CGFloat)progress {
    [self showProgress:progress interaction:NO];
}

+ (void)showProgress:(CGFloat)progress interaction:(BOOL)interaction {
    [self showProgress:progress status:@"" interaction:interaction];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status interaction:(BOOL)interaction {
    dispatch_async(dispatch_get_main_queue(), ^{
        DProgressHUD.animationType = DProgressHUDAnimationprogress;
        [[DProgressHUD shared] setupWithStatus:status progress:progress staticImage:nil hiden:NO interaction:interaction];
    });
}

#pragma mark Image

+ (void)showImage:(UIImage *)image {
    [self showImage:image status:@""];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status {
    [self showImage:image status:status interaction:YES];
}

+ (void)showImage:(UIImage *)image interaction:(BOOL)interaction {
    [self showImage:image status:@"" interaction:interaction];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status interaction:(BOOL)interaction {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DProgressHUD shared] setupWithStatus:status progress:0 staticImage:image hiden:YES interaction:interaction];
    });
}

#pragma mark Only Text

+ (void)showText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        DProgressHUD.animationType = DProgressHUDAnimationNone;
        [[DProgressHUD shared] setupWithStatus:text progress:0 staticImage:nil hiden:YES interaction:YES];
    });
}

#pragma mark - Properties`s Getter && Setter

+ (DProgressHUDAnimationType)animationType {
    return [DProgressHUD shared].animationType;
}

+ (void)setAnimationType:(DProgressHUDAnimationType)animationType {
    [DProgressHUD shared].animationType = animationType;
}

+ (UIColor *)colorBackground {
    return [DProgressHUD shared].colorBackground;
}

+ (void)setColorBackground:(UIColor *)colorBackground {
    [DProgressHUD shared].colorBackground = colorBackground;
}

+ (UIColor *)colorHUD {
    return [DProgressHUD shared].colorBackground;
}

+ (void)setColorHUD:(UIColor *)colorHUD {
    [DProgressHUD shared].colorHUD = colorHUD;
}

+ (UIColor *)colorAnimation {
    return [DProgressHUD shared].colorAnimation;
}

+ (void)setColorAnimation:(UIColor *)colorAnimation {
    [DProgressHUD shared].colorAnimation = colorAnimation;
}

+ (UIColor *)colorStatus {
    return [DProgressHUD shared].colorStatus;
}

+ (void)setColorStatus:(UIColor *)colorStatus {
    [DProgressHUD shared].colorStatus = colorStatus;
}

+ (UIColor *)colorProgress {
    return [DProgressHUD shared].colorProgress;
}

+ (void)setColorProgress:(UIColor *)colorProgress {
    [DProgressHUD shared].colorProgress = colorProgress;
}

+ (UIFont *)fontStatus {
    return [DProgressHUD shared].fontStatus;
}

+ (void)setFontStatus:(UIFont *)fontStatus {
    [DProgressHUD shared].fontStatus = fontStatus;
}
@end


#pragma mark - Category Animations
@implementation DProgressHUD (Animation)
// 系统菊花
- (void)animationSystemActivityIndicatorWithView:(UIView *)view {
    UIActivityIndicatorView *spinner = nil;
    if (@available(iOS 13.0, *)) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
    } else {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    }
    spinner.frame = view.bounds;
    spinner.color = self.colorAnimation;
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    spinner.transform = CGAffineTransformMakeScale(1.6, 1.6);
    [view addSubview:spinner];
}

// 横向三个圈
- (void)animationHorizontalCirclesPulseWithView:(UIView *)view {
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    
    CGFloat spacing = 3;
    CGFloat radius = (width - spacing * 2) / 3;
    CGFloat ypos = (height - radius) / 2;
    
    CFTimeInterval beginTimer = CACurrentMediaTime();
    NSArray *beginTimes = @[@(0.36), @(0.24), @(0.12)];
    CAMediaTimingFunction *timerFunction = [CAMediaTimingFunction functionWithControlPoints:0.2 :0.68 :0.18 :1.08];

    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.keyTimes = @[@(0), @(0.5), @(1)];
    animation.timingFunctions = @[timerFunction, timerFunction];
    animation.values = @[@(1), @(0.3), @(1)];
    animation.duration = 1;
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius / 2, radius / 2) radius:radius / 2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake((radius + spacing) * i, ypos, radius, radius);
        shapeLayer.path = [path CGPath];
        shapeLayer.fillColor = self.colorAnimation.CGColor;
        animation.beginTime = beginTimer - [beginTimes[i] doubleValue];
        [shapeLayer addAnimation:animation forKey:@"animation"];
        [view.layer addSublayer:shapeLayer];
    }
}

// 横向排列5个竖线
- (void)animationLineScalingWithView:(UIView *)view {
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    
    CGFloat lineWidth = width / 9;
    CFTimeInterval beginTimer = CACurrentMediaTime();
    NSArray *beginTimes = @[@(0.5), @(0.4), @(0.3), @(0.2), @(0.1)];
    CAMediaTimingFunction *timerFunction = [CAMediaTimingFunction functionWithControlPoints:0.2 :0.68 :0.18 :1.08];

    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    animation.keyTimes = @[@(0), @(0.5), @(1)];
    animation.timingFunctions = @[timerFunction, timerFunction];
    animation.values = @[@(1), @(0.4), @(1)];
    animation.duration = 1;
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lineWidth, height) cornerRadius:width / 2];
    
    for (int i = 0; i < 5; i++) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(lineWidth * 2 * i, 0, lineWidth, height);
        shapeLayer.path = [path CGPath];
        shapeLayer.fillColor = self.colorAnimation.CGColor;
        animation.beginTime = beginTimer - [beginTimes[i] doubleValue];
        [shapeLayer addAnimation:animation forKey:@"animation"];
        [view.layer addSublayer:shapeLayer];
    }
}

// 8圆圈，围成一个圈，透明度和尺寸改变
- (void)animationCircleSpinFadeWithView:(UIView *)view {
    CGFloat width = view.frame.size.width;
    CGFloat spacing = 3;
    CGFloat radius = (width - 4 * spacing) / 3.5;
    CGFloat radiusX = (width - radius) / 2;
    
    CGFloat duration = 1.0;
    CFTimeInterval beginTime = CACurrentMediaTime();
    NSArray *beginTimes = @[@(0.84), @(0.72), @(0.6), @(0.48), @(0.36), @(0.24), @(0.12), @(0)];
    
    
    CAKeyframeAnimation *animationScale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animationScale.duration = duration;
    animationScale.keyTimes = @[@(0), @(0.5), @(1)];
    animationScale.values = @[@(1), @(0.4), @(1)];
    
    
    CAKeyframeAnimation *animationOpacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animationOpacity.duration = duration;
    animationOpacity.keyTimes = @[@(0), @(0.5), @(1)];
    animationOpacity.values = @[@(1), @(0.3), @(1)];
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[animationScale, animationOpacity];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = duration;
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius / 2, radius / 2) radius:radius / 2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    
    for (int i = 0; i < 8; i++) {
        double angle = M_PI / 4 * i;
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(radiusX * (cos(angle) + 1), radiusX * (sin(angle) + 1), radius, radius);
        layer.path = path.CGPath;
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.fillColor = self.colorAnimation.CGColor;
        animation.beginTime = beginTime - [beginTimes[i] doubleValue];
        [layer addAnimation:animation forKey:@"animation"];
        [view.layer addSublayer:layer];
    }
}

// 8竖线，围成一个圈，透明度改变
- (void)animationLineSpinFadeWithView:(UIView *)view {
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    
    CGFloat spacing = 3;
    CGFloat lineWidth = (width - 4 * spacing) / 5;
    CGFloat lineHeight = (height - 2 * spacing) / 3;
    CGFloat containerSize = MAX(lineWidth, lineHeight);
    CGFloat radius = width / 2 - containerSize / 2;
    
    CGFloat duration = 1.2;
    CFTimeInterval beginTime = CACurrentMediaTime();
    NSArray *beginTimes = @[@(0.96), @(0.84), @(0.72), @(0.6), @(0.48), @(0.36), @(0.24), @(0.12)];
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAKeyframeAnimation *animationOpacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animationOpacity.duration = duration;
    animationOpacity.keyTimes = @[@(0), @(0.5), @(1)];
    animationOpacity.values = @[@(1), @(0.3), @(1)];
    animationOpacity.timingFunctions = @[timingFunction, timingFunction];
    animationOpacity.repeatCount = HUGE;
    animationOpacity.removedOnCompletion = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lineWidth, lineHeight) cornerRadius:lineWidth / 2];

    for (int i = 0; i < 8; i++) {
        double angle = M_PI / 4 * i;

        CAShapeLayer *line = [CAShapeLayer layer];
        line.frame = CGRectMake((containerSize - lineWidth) / 2, (containerSize - lineHeight) / 2, lineWidth, lineHeight);
        line.path = path.CGPath;
        line.backgroundColor = [UIColor clearColor].CGColor;
        line.fillColor = self.colorAnimation.CGColor;
        
        CALayer *containerLayer = [CALayer layer];
        containerLayer.frame = CGRectMake(radius * (cos(angle) + 1), radius * (sin(angle) + 1), containerSize, containerSize);
        [containerLayer addSublayer:line];
        containerLayer.sublayerTransform = CATransform3DMakeRotation(M_PI / 2 + angle, 0, 0, 1);
        
        animationOpacity.beginTime = beginTime - [beginTimes[i] doubleValue];
        [containerLayer addAnimation:animationOpacity forKey:@"animation"];
        [view.layer addSublayer:containerLayer];
    }
}

// 5个圆 绕圆心旋转 修改尺寸
- (void)animationCircleRotateChaseWithView:(UIView *)view {
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    
    CGFloat spacing = 3;
    CGFloat radius = (width - 4 * spacing) / 3.5;
    CGFloat radiusX = (width - radius) / 2;
    
    CFTimeInterval duration = 1.5;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius / 2, radius / 2) radius:radius / 2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    UIBezierPath *pathPosition = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:radiusX startAngle:1.5 * M_PI endAngle:3.5 * M_PI clockwise:YES];

    for (int i = 0; i < 5; i++) {
        CGFloat rate = (CGFloat)(i) * 1 / 5;
        CGFloat fromScale = 1 - rate;
        CGFloat toScale = 0.2 + rate;
        CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5 :0.15 + rate :0.25 :1];

        CABasicAnimation *animationScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animationScale.duration = duration;
        animationScale.repeatCount = HUGE;
        animationScale.fromValue = @(fromScale);
        animationScale.toValue = @(toScale);

        CAKeyframeAnimation *animationPosition = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animationPosition.duration = duration;
        animationPosition.repeatCount = HUGE;
        animationPosition.path = pathPosition.CGPath;

        CAAnimationGroup *animation = [CAAnimationGroup animation];
        animation.animations = @[animationScale, animationPosition];
        animation.timingFunction = timingFunction;
        animation.duration = duration;
        animation.repeatCount = HUGE;
        animation.removedOnCompletion = NO;

        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(0, 0, radius, radius);
        layer.path = path.CGPath;
        layer.fillColor = self.colorAnimation.CGColor;
        [layer addAnimation:animation forKey:@"animation"];
        [view.layer addSublayer:layer];
    }
}

// 仿安卓Loading
- (void)animationCircleStrokeSpinWithView:(UIView *)view {
    
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    
    NSTimeInterval beginTime = 0.5;
    NSTimeInterval durationStart = 1.2;
    NSTimeInterval durationStop = 0.7;
    
    CABasicAnimation *animationRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animationRotation.byValue = @(2 * M_PI);
    animationRotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    

    CABasicAnimation *animationStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animationStart.duration = durationStart;
    animationStart.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0.2 :1];
    animationStart.fromValue = @0;
    animationStart.toValue = @1;
    animationStart.beginTime = beginTime;
    
    CABasicAnimation *animationStop = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animationStop.duration = durationStop;
    animationStop.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0.2 :1];
    animationStop.fromValue = @0;
    animationStop.toValue = @1;
    
    CAAnimationGroup *animation = [[CAAnimationGroup alloc] init];
    animation.animations = @[animationRotation, animationStop, animationStart];
    animation.duration = durationStart + beginTime;
    animation.repeatCount = CGFLOAT_MAX;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2.0, height / 2.0)
                                                        radius:width / 2
                                                    startAngle:-0.5 * M_PI
                                                      endAngle:1.5 * M_PI
                                                     clockwise:YES];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    layer.fillColor = nil;
    layer.strokeColor = self.colorAnimation.CGColor;
    layer.lineWidth = 3;
    [layer addAnimation:animation forKey:@"animation"];
    [view.layer addSublayer:layer];
}

//  显示对号
- (void)animationSuccessWithView:(UIView *)view {
    CGFloat lineWidth = 2.0f;
    CGFloat duration = 0.5f;
    
    CALayer *layer = view.layer;
    CGSize size = view.bounds.size;
    
    CGFloat oX = (layer.bounds.size.width-size.width)*0.5;
    CGFloat oY = (layer.bounds.size.height-size.height)*0.5;
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = CGRectMake(oX, oY, size.width, size.height);
    circleLayer.fillColor =  [[UIColor clearColor] CGColor];
    circleLayer.strokeColor  = self.colorAnimation.CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.lineCap = kCALineCapRound;
    [layer addSublayer:circleLayer];
    
    
    CGFloat radius = size.width/2.0f - lineWidth/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(circleLayer.frame.size.width*0.5, circleLayer.frame.size.height*0.5) radius:radius startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:true];
    circleLayer.path = path.CGPath;
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = duration;
    circleAnimation.fromValue = @(0.0f);
    circleAnimation.toValue = @(1.0f);
    circleAnimation.autoreverses = NO;
    circleAnimation.fillMode = kCAFillModeForwards;
    circleAnimation.removedOnCompletion = false;
    [circleAnimation setValue:@"circleAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:circleAnimation forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat a = circleLayer.bounds.size.width;
        
        UIBezierPath *checkPath = [UIBezierPath bezierPath];
        [checkPath moveToPoint:CGPointMake(a*2.7/10,a*5.4/10)];
        [checkPath addLineToPoint:CGPointMake(a*4.5/10,a*7/10)];
        [checkPath addLineToPoint:CGPointMake(a*7.8/10,a*3.8/10)];
        
        CAShapeLayer *checkLayer = [CAShapeLayer layer];
        checkLayer.path = checkPath.CGPath;
        checkLayer.fillColor = [UIColor clearColor].CGColor;
        checkLayer.strokeColor = self.colorAnimation.CGColor;
        checkLayer.lineWidth = lineWidth;
        checkLayer.lineCap = kCALineCapRound;
        checkLayer.lineJoin = kCALineJoinRound;
        [circleLayer addSublayer:checkLayer];
        
        CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        checkAnimation.duration = duration;
        checkAnimation.fromValue = @(0.0f);
        checkAnimation.toValue = @(1.0f);
        checkAnimation.autoreverses = NO;
        checkAnimation.fillMode = kCAFillModeForwards;
        checkAnimation.removedOnCompletion = false;
        [checkAnimation setValue:@"checkAnimation" forKey:@"checkAnimation"];
        [checkLayer addAnimation:checkAnimation forKey:nil];
    });
}

//  显示叉
- (void)animationFailedWithView:(UIView *)view {
    CGFloat lineWidth = 2.0f;
    CGFloat duration = 0.5f;
    
    CALayer *layer = view.layer;
    CGSize size = view.bounds.size;
    
    CGFloat oX = (layer.bounds.size.width-size.width)*0.5;
    CGFloat oY = (layer.bounds.size.height-size.height)*0.5;
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = CGRectMake(oX, oY, size.width, size.height);
    circleLayer.fillColor =  [[UIColor clearColor] CGColor];
    circleLayer.strokeColor  = self.colorAnimation.CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.lineCap = kCALineCapRound;
    [layer addSublayer:circleLayer];
    
    
    CGFloat radius = size.width/2.0f - lineWidth/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(circleLayer.frame.size.width*0.5, circleLayer.frame.size.height*0.5) radius:radius startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:true];
    circleLayer.path = path.CGPath;
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = duration;
    circleAnimation.fromValue = @(0.0f);
    circleAnimation.toValue = @(1.0f);
    circleAnimation.autoreverses = NO;
    circleAnimation.fillMode = kCAFillModeForwards;
    circleAnimation.removedOnCompletion = false;
    [circleAnimation setValue:@"circleAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:circleAnimation forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CGFloat a = circleLayer.bounds.size.width;
        
        CGFloat x0 = circleLayer.frame.size.width*0.5;
        CGFloat y0 = circleLayer.frame.size.height*0.5;
        
        CGFloat x = x0 + radius * cos(-M_PI*3/4);
        CGFloat y = y0 + radius * sin(-M_PI*3/4);

        CGFloat margin = 4;
        UIBezierPath *chaPath1 = [UIBezierPath bezierPath];
        [chaPath1 moveToPoint:CGPointMake(x+lineWidth*0.5+margin,y+lineWidth*0.5+margin)];
        [chaPath1 addLineToPoint:CGPointMake(a-x-lineWidth*0.5-margin,a-y-lineWidth*0.5-margin)];
        
        CAShapeLayer *chaLayer1 = [CAShapeLayer layer];
        chaLayer1.path = chaPath1.CGPath;
        chaLayer1.fillColor = [UIColor clearColor].CGColor;
        chaLayer1.strokeColor = self.colorAnimation.CGColor;
        chaLayer1.lineWidth = lineWidth;
        chaLayer1.lineCap = kCALineCapRound;
        chaLayer1.lineJoin = kCALineJoinRound;
        [circleLayer addSublayer:chaLayer1];
        
        CABasicAnimation *checkAnimation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        checkAnimation1.duration = duration;
        checkAnimation1.fromValue = @(0.0f);
        checkAnimation1.toValue = @(1.0f);
        checkAnimation1.autoreverses = NO;
        checkAnimation1.fillMode = kCAFillModeForwards;
        checkAnimation1.removedOnCompletion = false;
        [checkAnimation1 setValue:@"chaAnimation" forKey:@"chaAnimation1"];
        [chaLayer1 addAnimation:checkAnimation1 forKey:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            CGFloat x0 = circleLayer.frame.size.width*0.5;
            CGFloat y0 = circleLayer.frame.size.height*0.5;
            
            CGFloat x = x0 + radius * cos(-M_PI/4);
            CGFloat y = y0 + radius * sin(-M_PI/4);
            
            CGFloat margin = 4;
            UIBezierPath *chaPath2 = [UIBezierPath bezierPath];
            [chaPath2 moveToPoint:CGPointMake(x-lineWidth*0.5-margin,y+lineWidth*0.5+margin)];
            [chaPath2 addLineToPoint:CGPointMake(a-x+lineWidth*0.5+margin,a-y-lineWidth*0.5-margin)];
            
            CAShapeLayer *chaLayer2 = [CAShapeLayer layer];
            chaLayer2.path = chaPath2.CGPath;
            chaLayer2.fillColor = [UIColor clearColor].CGColor;
            chaLayer2.strokeColor = self.colorAnimation.CGColor;
            chaLayer2.lineWidth = lineWidth;
            chaLayer2.lineCap = kCALineCapRound;
            chaLayer2.lineJoin = kCALineJoinRound;
            [circleLayer addSublayer:chaLayer2];
            
            CABasicAnimation *checkAnimation2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            checkAnimation2.duration = duration;
            checkAnimation2.fromValue = @(0.0f);
            checkAnimation2.toValue = @(1.0f);
            checkAnimation2.autoreverses = NO;
            checkAnimation2.fillMode = kCAFillModeForwards;
            checkAnimation2.removedOnCompletion = false;
            [checkAnimation2 setValue:@"chaAnimation" forKey:@"chaAnimation2"];
            [chaLayer2 addAnimation:checkAnimation2 forKey:nil];
            
        });
    });
}
@end

@implementation DProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.color = [UIColor redColor];
        self.progress = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setupLayers];
}

- (void)setupLayers {
    for (UIView *view in self.subviews)          { [view removeFromSuperview]; }
    for (CALayer *layer in self.layer.sublayers) { [layer removeFromSuperlayer]; }

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    CGPoint center = CGPointMake(width / 2, height / 2);
    CGFloat radiusCircle = width / 2;
    CGFloat radiusProgress = width / 2 - 5;
    
    UIBezierPath *pathCircle = [UIBezierPath bezierPathWithArcCenter:center radius:radiusCircle startAngle:-0.5 * M_PI endAngle:1.5 * M_PI clockwise:YES];
    UIBezierPath *pathProgress = [UIBezierPath bezierPathWithArcCenter:center radius:radiusProgress startAngle:-0.5 * M_PI endAngle:1.5 * M_PI clockwise:YES];

    self.layerCicle = [[CAShapeLayer alloc] init];
    self.layerCicle.path = pathCircle.CGPath;
    self.layerCicle.fillColor = [[UIColor clearColor] CGColor];
    self.layerCicle.lineWidth = 3;
    self.layerCicle.strokeColor = self.color.CGColor;

    self.layerProgress = [[CAShapeLayer alloc] init];
    self.layerProgress.path = [pathProgress CGPath];
    self.layerProgress.fillColor = [[UIColor clearColor] CGColor];
    self.layerProgress.lineWidth = 7;
    self.layerProgress.strokeColor = self.color.CGColor;
    self.layerProgress.strokeEnd = 0;
    
    [self.layer addSublayer:self.layerCicle];
    [self.layer addSublayer:self.layerProgress];

    self.labelPercentage = [[UILabel alloc] init];
    self.labelPercentage.frame = self.bounds;
    self.labelPercentage.textColor = self.color;
    self.labelPercentage.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.labelPercentage];
}

- (void)setProgressWithValue:(CGFloat)value duration:(NSTimeInterval)duration {
    self.labelPercentage.text = [NSString stringWithFormat:@"%d%@", (int)(value * 100), @"%"];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = duration;
    animation.fromValue = @(self.progress);
    animation.toValue = @(value);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [self.layerProgress addAnimation:animation forKey:@"animation"];
    self.progress = value;
}

@end
