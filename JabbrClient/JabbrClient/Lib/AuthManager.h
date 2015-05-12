//
//  AuthManager.h
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthManager : NSObject

//TODO: remove
@property (strong, nonatomic, readonly) NSString *server_url;

+ (AuthManager *)sharedInstance;

- (BOOL)isAuthenticated;

- (void)signOut;

- (NSString *)getCachedAuthToken;
- (NSString *)getUsername;

- (void)cacheAuthToken: (NSString *)authToken;
- (void)cacheUsername:(NSString *)username;
@end
