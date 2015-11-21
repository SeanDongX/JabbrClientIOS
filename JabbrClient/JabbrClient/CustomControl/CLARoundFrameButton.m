//
//  CLARoundFrameButton.m
//  Collara
//
//  Created by Sean on 30/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLARoundFrameButton.h"
#import "Constants.h"

@implementation CLARoundFrameButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setButtonStyle:[Constants mainThemeColor]];
}

- (void)setButtonStyle:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateNormal];
    //[self.titleLabel setTextColor:color];
    [[self layer] setCornerRadius:5.0f];
    [[self layer] setMasksToBounds:YES];
    [[self layer] setBorderWidth:1.0f];
    [[self layer] setBorderColor:color.CGColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setButtonStyle:[Constants mainThemeColor]];
    return self;
}
@end
