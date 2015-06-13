//
//  CLAAzureHubPushNotificationService.h
//  Collara
//
//  Created by Sean on 13/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAPushNotificationService.h"

@interface CLAAzureHubPushNotificationService : NSObject <CLAPushNotificationService>

+ (id)sharedInstance;

@end
