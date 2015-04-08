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

FOUNDATION_EXPORT NSString *const kChatNavigationController;
FOUNDATION_EXPORT NSString *const kSignInNavigationController;
FOUNDATION_EXPORT NSString *const kProfileNavigationController;
FOUNDATION_EXPORT NSString *const kLeftMenuViewController;
FOUNDATION_EXPORT NSString *const kRightMenuViewController;

FOUNDATION_EXPORT NSString * const kUsername;
FOUNDATION_EXPORT NSString * const kAuthToken;
FOUNDATION_EXPORT NSString * const kLastAuthDate;

FOUNDATION_EXPORT int const kMessageLoadAnimateTimeThreshold;

+ (UIImage *)menuIconImage;
+ (UIImage *)chatIconImage;
+ (UIImage *)docIconImage;
+ (UIColor *)mainThemeColor;
@end
