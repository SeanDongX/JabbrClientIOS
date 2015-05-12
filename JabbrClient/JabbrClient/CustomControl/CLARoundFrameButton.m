//
//  CLARoundFrameButton.m
//  Collara
//
//  Created by Sean on 30/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLARoundFrameButton.h"

@implementation CLARoundFrameButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setButtonStyle];
}

- (void)setButtonStyle {
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [[self layer] setCornerRadius:5.0f];
    [[self layer] setMasksToBounds:YES];
    [[self layer] setBorderWidth:1.0f];
    [[self layer] setBorderColor:[UIColor whiteColor].CGColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setButtonStyle];
    return self;
}
@end