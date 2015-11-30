//
//  CLAToastManager.h
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, CLANotificationType) {
    CLANotificationTypeMessage = 0,
    CLANotificationTypeWarning,
    CLANotificationTypeError,
    CLANotificationTypeSuccess
};

@interface CLANotificationManager : NSObject

+ (void)configure;
+ (void)showText:(NSString *)text
forViewController:(UIViewController *)viewController
        withType:(CLANotificationType)type;
+ (void)dismiss;

@end
