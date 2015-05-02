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

FOUNDATION_EXPORT NSString *const kServerBaseUrl;

FOUNDATION_EXPORT NSString *const kChatNavigationController;
FOUNDATION_EXPORT NSString *const kSignInNavigationController;
FOUNDATION_EXPORT NSString *const kSignUpController;
FOUNDATION_EXPORT NSString *const kProfileNavigationController;
FOUNDATION_EXPORT NSString *const kDocumentNavigationController;

FOUNDATION_EXPORT NSString *const kLeftMenuViewController;
FOUNDATION_EXPORT NSString *const kRightMenuViewController;

FOUNDATION_EXPORT NSString *const kChatInfoViewController;

FOUNDATION_EXPORT NSString *const kUsername;
FOUNDATION_EXPORT NSString *const kAuthToken;
FOUNDATION_EXPORT NSString *const kLastAuthDate;
FOUNDATION_EXPORT NSString *const kTeamKey;

FOUNDATION_EXPORT int const kMessageLoadAnimateTimeThreshold;

FOUNDATION_EXPORT NSString *const kErrorDoamin;
FOUNDATION_EXPORT NSString *const kErrorDescription;

FOUNDATION_EXPORT int const kErrorCodeSignInUsernameOrPasswordInvalid;

FOUNDATION_EXPORT NSString *const kErrorMsgSignInUsernameOrPasswordInvalid;

FOUNDATION_EXPORT NSString *const kErrorMsgSignInFailureUnknown;


+ (NSDictionary *)toasOptions;

+ (UIImage *)menuIconImage;
+ (UIImage *)chatIconImage;
+ (UIImage *)docIconImage;
+ (UIImage *)infoIconImage;
+ (UIImage *)closeIconImage;
+ (UIColor *)mainThemeColor;
+ (UIColor*)mainThemeContrastColor;
+ (UIColor*)warningColor;
@end
