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
    [TSMessage addCustomDesignFromFileWithName:
     @"CustomTSMessageNotificationDesign.json"];
}

+ (void)showText:(NSString *)text
forViewController:(UIViewController *)viewController
        withType:(CLANotificationType)type {
    [TSMessage setDefaultViewController:viewController];
    [TSMessage showNotificationWithTitle:text
                                    type:(TSMessageNotificationType)type];
}

+ (void)showText:(NSString *)text
forViewController:(UIViewController *)viewController
        withType:(CLANotificationType)type
     autoDismiss:(BOOL) autoDismiss
      atPosition:(NSInteger)pisition {
    
    [TSMessage setDefaultViewController:viewController];
    [TSMessage showNotificationInViewController:viewController
                                          title:text
                                       subtitle:nil
                                          image:nil
                                           type:(TSMessageNotificationType)type
                                       duration: autoDismiss == YES ? 0 : -1
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:pisition
                           canBeDismissedByUser:NO];
}

+ (void)dismiss {
    [TSMessage dismissActiveNotification];
}
@end
