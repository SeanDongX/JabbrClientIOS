//
//  Constants.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "Constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "CRToast.h"

@implementation Constants

NSString *const kServerBaseUrl =
@"http://192.168.31.202:16207/";
//@"http://colla-team.azurewebsites.net/";

//NSString *const kServerBaseUrl = @"http://www.collara.co/";

NSString *const kChatNavigationController = @"ChatNavigationController";
NSString *const kSignInNavigationController = @"SignInNavigationController";
NSString *const kSignUpController = @"SignUpController";

NSString *const kProfileNavigationController = @"ProfileNavigationController";
NSString *const kDocumentNavigationController = @"DocumentNavigationController";

NSString *const kLeftMenuViewController = @"LeftMenuViewController";
NSString *const kRightMenuViewController = @"RightMenuViewController";

NSString *const kUsername = @"Username";
NSString *const kAuthToken = @"AuthToken";
NSString *const kLastAuthDate = @"LastAuthDate";
NSString *const kTeamKey = @"TeamKey";
int const kMessageLoadAnimateTimeThreshold = 60;

NSString *const kErrorDoamin = @"com.collara";
NSString *const kErrorDescription = @"ErrorDescription";

int const kErrorCodeSignInUsernameOrPasswordInvalid = 100;
NSString *const kErrorMsgSignInUsernameOrPasswordInvalid = @"We can not sign you in with that username and password.";

NSString *const kErrorMsgSignInFailureUnknown = @"Something went wrong. How about another try?";

+ (NSDictionary *)toasOptions {
    return @{
             kCRToastFontKey: [UIFont systemFontOfSize:16],
             kCRToastTextColorKey: [UIColor whiteColor],
             kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
             kCRToastTextAlignmentKey: @(NSTextAlignmentLeft),
             kCRToastBackgroundColorKey : [Constants warningColor],
             kCRToastTimeIntervalKey: @3,
             kCRToastAnimationInTypeKey: @(CRToastAnimationTypeGravity),
             kCRToastAnimationOutTypeKey: @(CRToastAnimationTypeGravity),
             kCRToastAnimationInDirectionKey: @(CRToastAnimationDirectionTop),
             kCRToastAnimationOutDirectionKey: @(CRToastAnimationDirectionTop)
            };
}

+ (UIImage *)menuIconImage {
    FAKIonIcons *menuIcon = [FAKIonIcons iosMoreOutlineIconWithSize:30];
    [menuIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [menuIcon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)chatIconImage {
    FAKIonIcons *chatIcon = [FAKIonIcons iosChatbubbleOutlineIconWithSize:30];
    [chatIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [chatIcon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)docIconImage {
    FAKIonIcons *docIcon = [FAKIonIcons iosPaperOutlineIconWithSize:30];
    [docIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [docIcon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)infoIconImage {
    FAKIonIcons *cogIcon = [FAKIonIcons iosInformationOutlineIconWithSize:30];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [cogIcon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIColor*)mainThemeColor {
    return [UIColor colorWithRed:(26/255.0) green:(179/255.0) blue:(148/255.0) alpha:1];
}

+ (UIColor*)mainThemeContrastColor {
    return [UIColor colorWithRed:(47/255.0) green:(64/255.0) blue:(80/255.0) alpha:1];
}

+ (UIColor*)warningColor {
    return [UIColor colorWithRed:(246/255.0) green:(95/255.0) blue:(77/255.0) alpha:1];
}
@end
