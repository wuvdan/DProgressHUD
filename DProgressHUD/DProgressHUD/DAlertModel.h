//
//  DAlertModel.h
//  DProgressHUD
//
//  Created by wudan on 2020/7/20.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DAlertActionModel : NSObject
@property (nonatomic, strong) UIFont *actionFont;
@property (nonatomic, strong) UIColor *actionColor;
@property (nonatomic, copy) NSString *actionTitle;
@end

@interface DAlertModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, strong) UIColor *subTitleColor;
@property (nonatomic, strong) UIFont *subTitleFont;

@property (nonatomic, copy) NSArray<DAlertActionModel *> *actions;
@end

NS_ASSUME_NONNULL_END
