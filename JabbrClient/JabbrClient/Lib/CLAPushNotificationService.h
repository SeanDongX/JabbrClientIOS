//
//  CLAPushNotificationService.h
//  Collara
//
//  Created by Sean on 13/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLAPushNotificationService;

@protocol CLAPushNotificationService <NSObject>

- (void)registerDevice;
- (void)unregisterDevice;

@end
