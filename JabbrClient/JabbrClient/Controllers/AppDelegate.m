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

//Menu
#import "LeftMenuViewController.h"

@interface AppDelegate()

@property (strong, nonatomic) UILocalNotification *lastLocalNotification;

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerLocalNotification];
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [self processLocalNotificaton:self.lastLocalNotification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    self.lastLocalNotification = notification;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)registerLocalNotification {
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (void)processLocalNotificaton: (UILocalNotification *)notification {
    if (notification.userInfo != nil) {
        NSString *room = [notification.userInfo objectForKey:kRoomName];
        
        if (room != nil && self.slidingViewController != nil) {
            LeftMenuViewController *leftMenu = (LeftMenuViewController *)self.slidingViewController.underLeftViewController;
            
            if ([leftMenu respondsToSelector:@selector(selectRoom:closeMenu:)]) {
                [leftMenu selectRoom:room closeMenu:YES];
            }
        }
    }
}

@end
