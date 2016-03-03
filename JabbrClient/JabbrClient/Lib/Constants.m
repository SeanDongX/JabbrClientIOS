//
//  Constants.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "Constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <FontAwesomeKit/FAKFontAwesome.h>

@implementation Constants

#ifdef DEBUG

//NSString *const kServerBaseUrl = @"http://192.168.1.56:16207/";
NSString *const kServerBaseUrl = @"http://beta.collara.co/";
NSString *const kTaskServiceRootUrl = @"http://task.collara.co/";

NSString *const kAuzreNotificationHubName = @"collarapush";
NSString *const kAzureNotificationHubConnectionString =
@"Endpoint=sb://collarapush.servicebus.windows.net/"
@";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey="
@"PiHeM88D6LWhitL1452bcQ1rEnxzu55R/eVbKseOhos=";

#else

NSString *const kServerBaseUrl = @"http://www.collara.co/";
NSString *const kTaskServiceRootUrl = @"http://task.collara.co/";

FOUNDATION_EXPORT NSString *const kTaskServiceRootUrl;
FOUNDATION_EXPORT NSString *const kTaskAuthPagePath;


NSString *const kAuzreNotificationHubName = @"collarapushprod";
NSString *const kAzureNotificationHubConnectionString =
@"Endpoint=sb://collarapush.servicebus.windows.net/"
@";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey="
@"EPJy3FiyTILmIagkPX4f1YHP5rYG79BpZyj4FW0Xap8=";

#endif


NSString *const kApiPath = @"api/v1/";

NSString *const kTaskAuthPagePath = @"authframe.html";

NSString *const kForgotPasswordPath = @"account/requestresetpassword/";

NSTimeInterval const kMessageClientReconnectInterval = 5.0;

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

NSString *const kCreateTeamNavigationController = @"CreateTeamNavigationController";
NSString *const kCreateTeamViewController = @"CreateTeamViewController";

NSString *const kCreateRoomViewController = @"CreateRoomViewController";

NSString *const kNotificationContentViewController = @"NotificationContentViewController";

NSString *const kUserPrefix = @"@";
NSString *const kRoomPrefix = @"#";
NSString *const kDocPrefix = @">";

NSString *const kUsername = @"Username";

NSString *const kUser = @"User";
NSString *const kRealName = @"RealName";
NSString *const kInitials = @"Initials";
NSString *const kEmail = @"Email";
NSString *const kColor = @"Color";

NSString *const kAuthToken = @"AuthToken";
NSString *const kTeam = @"Team";
NSString *const kTeamName = @"TeamName";
NSString *const kTeamKey = @"TeamKey";

NSString *const kLastAuthDate = @"LastAuthDate";
NSString *const kDeviceToken = @"DeviceToken";
NSString *const kInviteCode = @"InviteCode";

NSString *const kTaskUsername = @"username";
NSString *const kTaskUserId = @"userId";
NSString *const kTaskAuthToken = @"token";
NSString *const kTaskAuthExpire = @"expires";

NSString *const kMessageId = @"MessageIdKey";
NSString *const kRoomName = @"RoomNameKey";

NSString *const kSelectedRoomName = @"SelectedRoomNameKey";

NSString *const kEventTeamUpdated = @"EventTeamUpdatedKey";
NSString *const kEventNoTeam = @"EventNoTeamKey";
NSString *const kEventReceiveUnread = @"EventReceiveUnreadKey";

NSString *const kNotificationKey = @"notificationKey";
NSString *const kinvitationId = @"invitationid";

int const kTeamNameMaxLength = 50;

double const minRoomRefreshInterval = 90;

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
NSTimeInterval const minRefreshLoadTime = 2;

NSString *const kFileUploadPath = @"upload-file";
NSString *const kFileUploadFile = @"file";
NSString *const kFileUploadType = @"type";
NSString *const kFileUploadRoom = @"room";
NSString *const kFileUploadFileName = @"filename";
NSString *const kMimeTypeJpeg = @"image/jpeg";

NSString *const kXLFormTextLabelColor = @"textLabel.color";

int const kMessageCellImageWidth = 160;
int const kMessageCellImageHeight = 90;

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
                  value:[Constants mainThemeContrastColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)signOutImage {
    FAKIonIcons *iccon = [FAKIonIcons logOutIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)optionsIconImage {
    FAKIonIcons *iccon = [FAKIonIcons iosMoreOutlineIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[UIColor whiteColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)taskIconImage {
    FAKFontAwesome *iccon = [FAKFontAwesome tasksIconWithSize:25];
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

+ (UIImage *)documentIconLarge {
    FAKFontAwesome *iccon = [FAKFontAwesome fileTextIconWithSize:100];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[Constants highlightColor]];
    return [iccon imageWithSize:CGSizeMake(210, 150)];
}

+ (UIImage *)cameraIcon {
    FAKIonIcons *iccon = [FAKIonIcons iosCameraIconWithSize:30];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[Constants highlightColor]];
    return [iccon imageWithSize:CGSizeMake(30, 30)];
}

+ (UIImage *)arrowRightIcon {
    FAKIonIcons *iccon = [FAKIonIcons iosArrowRightIconWithSize:10];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[Constants mainThemeContrastColor]];
    return [iccon imageWithSize:CGSizeMake(10, 10)];
}

+ (UIImage *)arrowDownIcon {
    FAKIonIcons *iccon = [FAKIonIcons iosArrowDownIconWithSize:10];
    [iccon addAttribute:NSForegroundColorAttributeName
                  value:[Constants mainThemeContrastColor]];
    return [iccon imageWithSize:CGSizeMake(10, 10)];
}

+ (UIColor *)mainThemeColor {
    return [UIColor colorWithRed:(27 / 255.0)
                           green:(188 / 255.0)
                            blue:(155 / 255.0)
                           alpha:1];
}

+ (UIColor *)highlightColor {
    return [UIColor colorWithRed:(102 / 255.0)
                           green:(196 / 255.0)
                            blue:(232 / 255.0)
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

+ (UIColor *)mutedTextColor {
    return [UIColor colorWithRed:(158 / 255.0)
                           green:(158 / 255.0)
                            blue:(166 / 255.0)
                           alpha:1];
}

+ (UIColor *)darkBackgroundColor {
    return [UIColor colorWithRed:(50 / 255.0)
                           green:(63 / 255.0)
                            blue:(81 / 255.0)
                           alpha:1];
}

@end
