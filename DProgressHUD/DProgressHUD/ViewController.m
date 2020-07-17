//
//  ViewController.m
//  DProgressHUD
//
//  Created by wudan on 2020/7/16.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "ViewController.h"
#import "DProgressHUD.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *items;
@end

@implementation ViewController

- (IBAction)hidenLoading:(id)sender {
    [DProgressHUD dimiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSArray array];
    
    NSArray *contentArray = @[@"系统菊花", @"仿安卓", @"三个圆圈", @"波浪", @"自定义菊花", @"圆追随", @"风火轮", @"下载进度", @"成功", @"失败", @"图片", @"仅文字"];
    self.items = @[contentArray, contentArray];
    DProgressHUD.colorHUD = [UIColor darkGrayColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.items count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items[section] count];;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"无文字", @"有文字"][section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.items[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
               case 0: [DProgressHUD showAnimateType:(DProgressHUDAnimationSystemActivityIndicator)]; break;
               case 1: [DProgressHUD show]; break;
               case 2: [DProgressHUD showAnimateType:(DProgressHUDAnimationHorizontalCirclesPulse)]; break;
               case 3: [DProgressHUD showAnimateType:(DProgressHUDAnimationLineScaling)]; break;
               case 4: [DProgressHUD showAnimateType:(DProgressHUDAnimationLineSpinFade)]; break;
               case 5: [DProgressHUD showAnimateType:(DProgressHUDAnimationCircleRotateChase)]; break;
               case 6: [DProgressHUD showAnimateType:(DProgressHUDAnimationCircleSpinFade)]; break;
               case 7:
               {
                   __block int count = 0;
                   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.025 repeats:YES block:^(NSTimer * _Nonnull timer) {
                       count += 1;
                       [DProgressHUD showProgress:count / 100.0];
                       if (count >= 100) {
                           [timer invalidate];
                           timer = nil;
                           [DProgressHUD dimiss];
                       }
                   }];
                   
                   [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
               }
                   break;
                case 8: [DProgressHUD showAnimateType:(DProgressHUDAnimationSuccess)]; break;
                case 9: [DProgressHUD showAnimateType:(DProgressHUDAnimationFailed)]; break;
                case 10: [DProgressHUD showImage:[UIImage imageNamed:@"info"]]; break;
                case 11: [DProgressHUD showText:@"登录成功~"]; break;
               default:
                   break;
           }
    } else {
        switch (indexPath.row) {
           case 0: [DProgressHUD showAnimateType:(DProgressHUDAnimationSystemActivityIndicator) status:@"Loading ..."]; break;
           case 1: [DProgressHUD showWithStatus:@"网络请求中..."]; break;
           case 2: [DProgressHUD showAnimateType:(DProgressHUDAnimationHorizontalCirclesPulse) status:@"Loading ..."]; break;
           case 3: [DProgressHUD showAnimateType:(DProgressHUDAnimationLineScaling) status:@"Loading ..."]; break;
           case 4: [DProgressHUD showAnimateType:(DProgressHUDAnimationLineSpinFade) status:@"Loading ..."]; break;
           case 5: [DProgressHUD showAnimateType:(DProgressHUDAnimationCircleRotateChase) status:@"Loading ..."]; break;
           case 6: [DProgressHUD showAnimateType:(DProgressHUDAnimationCircleSpinFade) status:@"Loading ..."]; break;
           case 7:
           {
               __block int count = 0;
               NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.025 repeats:YES block:^(NSTimer * _Nonnull timer) {
                   count += 1;
                   [DProgressHUD showProgress:count / 100.0 status:@"Loading ..."];
                   if (count >= 100) {
                       [timer invalidate];
                       timer = nil;
                       [DProgressHUD dimiss];
                   }
               }];
               
               [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
           }
               break;
            case 8: [DProgressHUD showSuccessWithStatus:@"上传成功~"]; break;
            case 9: [DProgressHUD showFailedWithStatus:@"下载失败~"]; break;
            case 10: [DProgressHUD showImage:[UIImage imageNamed:@"info"] status:@"请输入手机号"]; break;
            case 11: [DProgressHUD showText:@"登录成功~"]; break;
           default:
               break;
       }
    }
}

@end
