//
//  CLAAzureHubPushNotificationService.m
//  Collara
//
//  Created by Sean on 13/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAAzureHubPushNotificationService.h"

// Util
#import "Constants.h"
#import "UserDataManager.h"

// Data Model
#import "CLAUser.h"

// Services
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@interface CLAAzureHubPushNotificationService ()

@property(strong, nonatomic) SBNotificationHub *hub;

@end

@implementation CLAAzureHubPushNotificationService

static CLAAzureHubPushNotificationService *SINGLETON = nil;
static bool isFirstAccess = YES;

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return [[CLAAzureHubPushNotificationService alloc] init];
}

- (id)mutableCopy {
    return [[CLAAzureHubPushNotificationService alloc] init];
}

- (id)init {
    if (SINGLETON) {
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    self = [super init];
    
    self.hub = [[SBNotificationHub alloc]
                initWithConnectionString:kAzureNotificationHubConnectionString
                notificationHubPath:kAuzreNotificationHubName];
    return self;
}

#pragma mark -
#pragma mark CLAApiCleint Methods

- (void)registerDevice {
    NSData *deviceToken = [UserDataManager getCachedDeviceToken];
    
    if (deviceToken == nil) {
        NSLog(@"Device token not found in user defaults");
        return;
    }
    
    NSMutableSet *tagSet = [NSMutableSet set];
    NSString *username = [UserDataManager getUsername];
    if (username != nil) {
        [tagSet addObject:[CLAUser getHandle:username]];
    }
    
    [self.hub registerNativeWithDeviceToken:deviceToken
                                       tags:tagSet
                                 completion:^(NSError *error) {
                                     if (error != nil) {
                                         NSLog(@"Error registering device token for "
                                               @"notifications: %@",
                                               error);
                                     }
                                 }];
}

- (void)unregisterDevice {
    NSData *deviceToken = [UserDataManager getCachedDeviceToken];
    
    if (deviceToken == nil) {
        NSLog(@"Device token not found in user defaults");
        return;
    }
    
    [self.hub unregisterAllWithDeviceToken:
     deviceToken completion:^(NSError *error) {
         if (error != nil) {
             NSLog(@"Error unregistering device token for notifications: %@", error);
         }
     }];
}

@end
