//
//  AuthManager.h
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthManager : NSObject

+ (AuthManager *)sharedInstance;

- (BOOL)isAuthenticated;

- (void)signOut;

- (NSString *)getCachedAuthToken;
- (NSString *)getUsername;
- (NSString *)getTeamName;
- (NSData *)getCachedDeviceToken;

- (void)cacheAuthToken:(NSString *)authToken;
- (void)cacheUsername:(NSString *)username;
- (void)cacheTeamName:(NSString *)teamName;
- (void)cacheDeviceToken:(NSData *)deviceToken;
- (void)cacheTaskServiceAuthInfo:(NSDictionary *)data;
- (NSString *)getTaskAuthFrameUrl;

@end
