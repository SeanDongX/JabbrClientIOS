//
//  AppDelegate.m
//  SignalR
//
//  Created by Alex Billingsley on 11/7/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "AppDelegate.h"

//Util
#import "Constants.h"
#import "CLAUtility.h"
#import "AuthManager.h"
#import "CLAWebApiClient.h"
#import "CLAAzureHubPushNotificationService.h"

//Data Model
#import "CLANotification.h"
#import "CLAUser.h"

//Menu
#import "LeftMenuViewController.h"

@interface AppDelegate()

@property (strong, nonatomic) CLANotification *lastNotification;

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerNotification];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [self clearUnreadNotificationOnServer];
    }
    
    [self processNotificaton:self.lastNotification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    self.lastNotification = [[CLANotification alloc] init:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)registerNotification {
    UIApplication *application = [UIApplication sharedApplication];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[AuthManager sharedInstance] cacheDeviceToken:deviceToken];
    [[CLAAzureHubPushNotificationService sharedInstance] registerDevice];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError: (NSError *)error {
    NSLog(@"Failed to register device with error: %@", error.domain.description);
}

#pragma mark -
#pragma mark Private Methods

- (void)processNotificaton: (CLANotification *)notification {
    //TODO: process appurl
}

- (void)clearUnreadNotificationOnServer {
    [[CLAWebApiClient sharedInstance] setBadge:@0 forTeam:[CLAUtility getUserDefault:kTeamKey]];
}

@end
