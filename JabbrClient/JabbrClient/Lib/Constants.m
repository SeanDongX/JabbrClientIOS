//
//  Constants.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "Constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@implementation Constants

NSString *const kChatNavigationController = @"ChatNavigationController";
NSString *const kSignInNavigationController = @"SignInNavigationController";
NSString *const kProfileNavigationController = @"ProfileNavigationController";
NSString *const kLeftMenuViewController = @"LeftMenuViewController";
NSString *const kRightMenuViewController = @"RightMenuViewController";

NSString *const kUsername = @"Username";
NSString *const kAuthToken = @"AuthToken";
NSString *const kLastAuthDate = @"LastAuthDate";

int const kMessageLoadAnimateTimeThreshold = 60;

+ (UIImage *)menuIconImage {
    FAKIonIcons *menuIcon = [FAKIonIcons iosMoreOutlineIconWithSize:30];
    [menuIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [menuIcon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIColor*)mainThemeColor {
    return [UIColor colorWithRed:(26/255.0) green:(179/255.0) blue:(148/255.0) alpha:1];
}
@end
