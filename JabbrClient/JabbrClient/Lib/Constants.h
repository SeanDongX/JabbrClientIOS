//
//  Constants.h
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Constants : NSObject

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568) ? NO : YES)

FOUNDATION_EXPORT NSString *const kServerBaseUrl;
FOUNDATION_EXPORT NSString *const kApiPath;

FOUNDATION_EXPORT NSString *const kTaskServiceRootUrl;
FOUNDATION_EXPORT NSString *const kTaskAuthPagePath;


FOUNDATION_EXPORT NSString *const kForgotPasswordPath;

FOUNDATION_EXPORT NSString *const kAuzreNotificationHubName;
FOUNDATION_EXPORT NSString *const kAzureNotificationHubConnectionString;

FOUNDATION_EXPORT NSTimeInterval const kMessageClientReconnectInterval;

FOUNDATION_EXPORT NSString *const kMainStoryBoard;

FOUNDATION_EXPORT NSString *const kHomeNavigationController;
FOUNDATION_EXPORT NSString *const kHomeTopicViewController;
FOUNDATION_EXPORT NSString *const kHomeMemberViewController;

FOUNDATION_EXPORT NSString *const kChatNavigationController;
FOUNDATION_EXPORT NSString *const kSignInNavigationController;
FOUNDATION_EXPORT NSString *const kSignUpController;
FOUNDATION_EXPORT NSString *const kTaskNavigationController;
FOUNDATION_EXPORT NSString *const kProfileNavigationController;
FOUNDATION_EXPORT NSString *const kDocumentNavigationController;

FOUNDATION_EXPORT NSString *const kLeftMenuViewController;
FOUNDATION_EXPORT NSString *const kRightMenuViewController;

FOUNDATION_EXPORT NSString *const kCreateTeamNavigationController;
FOUNDATION_EXPORT NSString *const kCreateTeamViewController;

FOUNDATION_EXPORT NSString *const kCreateRoomViewController;

FOUNDATION_EXPORT NSString *const kNotificationContentViewController;

FOUNDATION_EXPORT NSString *const kUserPrefix;
FOUNDATION_EXPORT NSString *const kRoomPrefix;
FOUNDATION_EXPORT NSString *const kDocPrefix;

FOUNDATION_EXPORT NSString *const kUsername;
FOUNDATION_EXPORT NSString *const kUser;
FOUNDATION_EXPORT NSString *const kRealName;
FOUNDATION_EXPORT NSString *const kInitials;
FOUNDATION_EXPORT NSString *const kEmail;
FOUNDATION_EXPORT NSString *const kColor;

FOUNDATION_EXPORT NSString *const kAuthToken;
FOUNDATION_EXPORT NSString *const kTeam;
FOUNDATION_EXPORT NSString *const kTeamName;
FOUNDATION_EXPORT NSString *const kTeamKey;

FOUNDATION_EXPORT NSString *const kLastAuthDate;
FOUNDATION_EXPORT NSString *const kDeviceToken;
FOUNDATION_EXPORT NSString *const kInviteCode;

FOUNDATION_EXPORT NSString *const kTaskUsername;
FOUNDATION_EXPORT NSString *const kTaskUserId;
FOUNDATION_EXPORT NSString *const kTaskAuthToken;
FOUNDATION_EXPORT NSString *const kTaskAuthExpire;

FOUNDATION_EXPORT NSString *const kMessageId;
FOUNDATION_EXPORT NSString *const kRoomName;

FOUNDATION_EXPORT NSString *const kSelectedRoomName;

FOUNDATION_EXPORT NSString *const kEventTeamUpdated;
FOUNDATION_EXPORT NSString *const kEventNoTeam;
FOUNDATION_EXPORT NSString *const kEventReceiveUnread;

FOUNDATION_EXPORT NSString *const kNotificationKey;
FOUNDATION_EXPORT NSString *const kinvitationId;

FOUNDATION_EXPORT int const kTeamNameMaxLength;

FOUNDATION_EXPORT double const minRoomRefreshInterval;

FOUNDATION_EXPORT int const kMessageLoadAnimateTimeThreshold;

FOUNDATION_EXPORT float const kStatusBarHeight;

FOUNDATION_EXPORT NSTimeInterval const kMessageDisplayTimeGap;

FOUNDATION_EXPORT NSString *const kErrorDoamin;
FOUNDATION_EXPORT NSString *const kErrorDescription;

FOUNDATION_EXPORT NSString *const kNotificationAps;
FOUNDATION_EXPORT NSString *const kNotificationAlert;
FOUNDATION_EXPORT NSString *const kNotificationAppUrl;

FOUNDATION_EXPORT int const kLoadEarlierMessageCount;

FOUNDATION_EXPORT NSString *const kLastRefreshTime;
FOUNDATION_EXPORT NSTimeInterval const minRefreshLoadTime;

FOUNDATION_EXPORT NSString *const kFileUploadPath;
FOUNDATION_EXPORT NSString *const kFileUploadFile;
FOUNDATION_EXPORT NSString *const kFileUploadType;
FOUNDATION_EXPORT NSString *const kFileUploadRoom;
FOUNDATION_EXPORT NSString *const kFileUploadFileName;
FOUNDATION_EXPORT NSString *const kMimeTypeJpeg;

FOUNDATION_EXPORT NSString *const kXLFormTextLabelColor;

typedef NS_ENUM (NSInteger, RoomType) {
    RoomTypePulbic,
    RoomTypePrivate,
    RoomTypeDirect,
};

typedef NS_ENUM (NSInteger, MessageType) {
    MessageTypeText,
    MessageTypeImage,
    MessageTypeDocument,
};

+ (UIImage *)menuIconImage;
+ (UIImage *)homeImage;
+ (UIImage *)settingsImage;
+ (UIImage *)chatIconImage;
+ (UIImage *)docIconImage;
+ (UIImage *)infoIconImage;
+ (UIImage *)closeIconImage;
+ (UIImage *)addIconImage;
+ (UIImage *)signOutImage;
+ (UIImage *)optionsIconImage;
+ (UIImage *)taskIconImage;
+ (UIImage *)unreadIcon;
+ (UIImage *)documentIconLarge;

+ (UIColor *)mainThemeColor;
+ (UIColor *)highlightColor;
+ (UIColor *)mainThemeContrastColor;
+ (UIColor *)warningColor;
+ (UIColor *)backgroundColor;
+ (UIColor *)incomingMessageBubbleBackgroundColor;
@end
