//
//  CLAToastManager.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLANotificationManager.h"
#import "Constants.h"
#import "TSMessage.h"
#import <TSMessages/TSMessageView.h>

@implementation CLANotificationManager

+ (void)configure {
}

+ (void)showText:(NSString *)text forViewController:(UIViewController *)viewController withType: (CLANotificationType)type {
    
    if (type == CLANotificationTypeMessage) {
        [[TSMessageView appearance] setBackgroundColor:[Constants highlightColor]];
    }
    [TSMessage setDefaultViewController:viewController];
    [TSMessage showNotificationWithTitle:text type:(TSMessageNotificationType)type];
}
@end
