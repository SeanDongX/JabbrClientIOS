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

#ifdef DEBUG

    NSString *const kAuzreNotificationHubName = @"collarapush";

    #if TARGET_IPHONE_SIMULATOR

        //NSString *const kServerBaseUrl = @"http://192.168.31.202:16207/";
        NSString *const kServerBaseUrl = @"http://www.collara.co/";
    #else

        //NSString *const kServerBaseUrl = @"http://colla-team.azurewebsites.net/";
        NSString *const kServerBaseUrl = @"http://www.collara.co/";
    #endif

#else

    NSString *const kServerBaseUrl = @"http://www.collara.co/";
    NSString *const kAuzreNotificationHubName = @"collarapushprod";

#endif

NSString *const kApiPath = @"api/v1/";

NSString *const kAzureNotificationHubConnectionString = @"Endpoint=sb://collarapush.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=PiHeM88D6LWhitL1452bcQ1rEnxzu55R/eVbKseOhos=";

NSTimeInterval const kMessageClientReconnectInterval = 5.0;

BOOL const kFSDocumentEnabled = NO;

NSString *const kMainStoryBoard = @"Main";

NSString *const kHomeNavigationController = @"HomeNavigationController";
NSString *const kHomeTopicViewController = @"HomeTopicViewController";
NSString *const kHomeMemberViewController = @"HomeMemberViewController";

NSString *const kChatNavigationController = @"ChatNavigationController";
NSString *const kSignInNavigationController = @"SignInNavigationController";
NSString *const kSignUpController = @"SignUpController";

NSString *const kProfileNavigationController = @"ProfileNavigationController";
NSString *const kDocumentNavigationController = @"DocumentNavigationController";

NSString *const kLeftMenuViewController = @"LeftMenuViewController";
NSString *const kRightMenuViewController = @"RightMenuViewController";

NSString *const kChatInfoViewController = @"ChatInfoViewController";
NSString *const kCreateTeamViewController = @"CreateTeamViewController";
NSString *const kCreateRoomViewController = @"CreateRoomViewController";

NSString *const kUserPrefix = @"@";
NSString *const kRoomPrefix = @"#";
NSString *const kDocPrefix = @">";

NSString *const kUsername = @"Username";
NSString *const kAuthToken = @"AuthToken";
NSString *const kLastAuthDate = @"LastAuthDate";
NSString *const kTeamKey = @"TeamKey";
NSString *const kDeviceToken = @"DeviceToken";

NSString *const kMessageId = @"MessageIdKey";
NSString *const kRoomName = @"RoomNameKey";

NSString *const kEventTeamUpdated = @"EventTeamUpdatedKey";
NSString *const kEventNoTeam = @"EventNoTeamKey";
NSString *const kEventRoomUpdated = @"EventRoomUpdatedKey";

int const kTeamNameMaxLength = 50;

int const kMessageLoadAnimateTimeThreshold = 60;

float const kStatusBarHeight = 64.0;

NSTimeInterval const kMessageDisplayTimeGap = 180;

NSString *const kErrorDoamin = @"com.collara";
NSString *const kErrorDescription = @"ErrorDescription";

NSString *const kNotificationAps = @"aps";
NSString *const kNotificationAlert = @"alert";
NSString *const kNotificationAppUrl = @"appUrl";

int const kLoadEarlierMessageCount = 50;

NSString *const kLastRefreshTime = @"LastRefreshTimeKey";
NSTimeInterval const minRefreshLoadTime = 3;

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
    FAKIonIcons *iccon = [FAKIonIcons naviconIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)homeImage {
    FAKIonIcons *iccon = [FAKIonIcons iosHomeOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)settingsImage {
    FAKIonIcons *iccon = [FAKIonIcons iosGearOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)chatIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosChatbubbleOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)docIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosPaperOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)infoIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosInformationOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)closeIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosCloseOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)addIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosPlusOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)signOutImage {
    FAKIonIcons *iccon = [FAKIonIcons logOutIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIColor*)mainThemeColor {
    return [UIColor colorWithRed:(26/255.0) green:(179/255.0) blue:(148/255.0) alpha:1];
}

+ (UIColor*)tableHeaderColor {
    return [UIColor colorWithRed:(41/255.0) green:(56/255.0) blue:(70/255.0) alpha:1];
}

+ (UIColor*)highlightColor {
    return [UIColor colorWithRed:(52/255.0) green:(152/255.0) blue:(219/255.0) alpha:1];
}

+ (UIColor*)mainThemeContrastColor {
    return [UIColor colorWithRed:(47/255.0) green:(64/255.0) blue:(80/255.0) alpha:1];
}

+ (UIColor*)warningColor {
    return [UIColor colorWithRed:(237/255.0) green:(85/255.0) blue:(101/255.0) alpha:1];
}


@end
