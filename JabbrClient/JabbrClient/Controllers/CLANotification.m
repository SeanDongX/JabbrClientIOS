//
//  CLANotification.m
//  Collara
//
//  Created by Sean on 11/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLANotification.h"

#import "Constants.h"

@implementation CLANotification


-(instancetype)init: (NSDictionary *)dictionary {
    self = [self init];
    
    NSDictionary *notificationBody = [dictionary objectForKey:kNotificationAps];
    self.alert = [notificationBody objectForKey:kNotificationAlert];
    self.appUrl = [notificationBody objectForKey:kNotificationAppUrl];
    return  self;
}

@end
