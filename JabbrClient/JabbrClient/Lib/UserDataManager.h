//
//  AuthManager.h
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLATeam.h"
#import "CLAUser.h"

@interface UserDataManager : NSObject

+ (BOOL)isAuthenticated;

+ (void)signOut;

+ (void)cacheObject:(NSObject *)object forKey:(NSString *)key;
+ (id)getCachedObjectForKey:(NSString *)key;

+ (NSString *)getCachedAuthToken;
+ (NSString *)getUsername;
+ (CLATeam *)getTeam;
+ (CLAUser *)getUser;
+ (NSData *)getCachedDeviceToken;
+ (NSDate *)getLastRefrershTime;

+ (void)cacheAuthToken:(NSString *)authToken;
+ (void)cacheUsername:(NSString *)username;
+ (void)cacheTeam:(CLATeam *)team;
+ (void)cacheUser:(CLAUser *)user;
+ (void)cacheDeviceToken:(NSData *)deviceToken;
+ (void)cacheLastRefreshTime;
+ (void)cacheTaskServiceAuthInfo:(NSDictionary *)data;
+ (NSString *)getTaskAuthFrameUrl;

@end
