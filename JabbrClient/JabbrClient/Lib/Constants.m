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

#ifdef DEBUG

NSString *const kAuzreNotificationHubName = @"collarapush";
NSString *const kAzureNotificationHubConnectionString =
@"Endpoint=sb://collarapush.servicebus.windows.net/"
@";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey="
@"PiHeM88D6LWhitL1452bcQ1rEnxzu55R/eVbKseOhos=";

#if TARGET_IPHONE_SIMULATOR

NSString *const kServerBaseUrl = @"http://test.collara.co/";
#else

NSString *const kServerBaseUrl = @"http://test.collara.co/";
#endif

#else

NSString *const kServerBaseUrl = @"http://www.collara.co/";
NSString *const kAuzreNotificationHubName = @"collarapushprod";
NSString *const kAzureNotificationHubConnectionString =
@"Endpoint=sb://collarapush.servicebus.windows.net/"
@";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey="
@"EPJy3FiyTILmIagkPX4f1YHP5rYG79BpZyj4FW0Xap8=";

#endif

NSString *const kApiPath = @"api/v1/";

NSString *const kForgotPasswordPath = @"account/requestresetpassword/";

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

NSString *const kCreateTeamViewController = @"CreateTeamViewController";
NSString *const kCreateRoomViewController = @"CreateRoomViewController";

NSString *const kNotificationContentViewController =
@"NotificationContentViewController";

NSString *const kUserPrefix = @"@";
NSString *const kRoomPrefix = @"#";
NSString *const kDocPrefix = @">";

NSString *const kUsername = @"Username";
NSString *const kAuthToken = @"AuthToken";
NSString *const kLastAuthDate = @"LastAuthDate";
NSString *const kTeamKey = @"TeamKey";
NSString *const kDeviceToken = @"DeviceToken";
NSString *const kInviteCode = @"InviteCode";

NSString *const kMessageId = @"MessageIdKey";
NSString *const kRoomName = @"RoomNameKey";

NSString *const kSelectedRoomName = @"SelectedRoomNameKey";

NSString *const kEventTeamUpdated = @"EventTeamUpdatedKey";
NSString *const kEventNoTeam = @"EventNoTeamKey";
NSString *const kEventReceiveUnread = @"EventReceiveUnreadKey";

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

NSString *const kTopicName = @"TopicName";
NSString *const kLeaveTopicButton = @"LeaveTopicButton";
NSString *const kSendInviteButton = @"SendInviteButton";
NSString *const kInvitePrefix = @"Invite-";

+ (UIImage *)menuIconImage {
    FAKIonIcons *iccon = [FAKIonIcons naviconIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)homeImage {
    FAKIonIcons *iccon = [FAKIonIcons iosHomeOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)settingsImage {
    FAKIonIcons *iccon = [FAKIonIcons iosGearOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)chatIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosChatbubbleOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)docIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosPaperOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)infoIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosInformationOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)closeIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosCloseOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)addIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosPlusOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)signOutImage {
    FAKIonIcons *iccon = [FAKIonIcons logOutIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)topicSettingIcon {
    FAKIonIcons *iccon = [FAKIonIcons iosSettingsIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)unreadIcon {
    FAKIonIcons *iccon = [FAKIonIcons iosCircleFilledIconWithSize:10];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[Constants highlightColor]];
    return [iccon imageWithSize:CGSizeMake(10, 10)];
}

+ (UIColor *)mainThemeColor {
    return [UIColor colorWithRed:(26 / 255.0)
                           green:(179 / 255.0)
                            blue:(148 / 255.0)
                           alpha:1];
}

+ (UIColor *)tableHeaderColor {
    return [UIColor colorWithRed:(41 / 255.0)
                           green:(56 / 255.0)
                            blue:(70 / 255.0)
                           alpha:1];
}

+ (UIColor *)highlightColor {
    return [UIColor colorWithRed:(52 / 255.0)
                           green:(152 / 255.0)
                            blue:(219 / 255.0)
                           alpha:1];
}

+ (UIColor *)mainThemeContrastColor {
    return [UIColor colorWithRed:(47 / 255.0)
                           green:(64 / 255.0)
                            blue:(80 / 255.0)
                           alpha:1];
}

+ (UIColor *)warningColor {
    return [UIColor colorWithRed:(248 / 255.0)
                           green:(172 / 255.0)
                            blue:(89 / 255.0)
                           alpha:1];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:(223 / 255.0)
                           green:(223 / 255.0)
                            blue:(223 / 255.0)
                           alpha:1];
}

@end
