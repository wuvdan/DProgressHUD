//
//  TextFiledViewController.m
//  DProgressHUD
//
//  Created by wudan on 2020/7/17.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "TextFiledViewController.h"
#import "DProgressHUD.h"
@interface TextFiledViewController ()

@end

@implementation TextFiledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [DProgressHUD showText:@"Loading..."];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
