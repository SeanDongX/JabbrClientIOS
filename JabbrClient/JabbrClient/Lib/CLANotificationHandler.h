//
//  CLANotificationHandler.h
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLANotificationHandler : UIViewController

- (void)keyboardWillShow:(NSNotification *)notification withView:(UIView *)view;
- (void)keyboardWillHide:(NSNotification *)notification withView:(UIView *)view;

@end
