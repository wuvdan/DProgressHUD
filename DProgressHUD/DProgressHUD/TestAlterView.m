//
//  TestAlterView.m
//  DProgressHUD
//
//  Created by wudan on 2020/7/20.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "TestAlterView.h"

@implementation TestAlterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"回馈"];
        [self addSubview:self.imageView];
    }
    return self;
}

- (instancetype)init {
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"回馈"];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
