//
//  CLANotificationHandler.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLANotificationHandler.h"

@implementation CLANotificationHandler

- (void)keyboardWillShow:(NSNotification *)notification withView:(UIView *)view {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = view.frame;
        f.origin.y = -keyboardSize.height;
        view.frame = f;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification withView:(UIView *)view {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = view.frame;
        f.origin.y = 0.0f;
        view.frame = f;
    }];
}


@end
