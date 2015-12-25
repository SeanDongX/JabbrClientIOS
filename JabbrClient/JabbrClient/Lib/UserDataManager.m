//
//  AuthManager.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "UserDataManager.h"

// Util
#import "Constants.h"

// Services
#import "CLAAzureHubPushNotificationService.h"
#import "CLATeam.h"

@implementation UserDataManager

#pragma -
#pragma Public Methods

+ (BOOL)isAuthenticated {
    return [UserDataManager getCachedAuthToken] != nil;
}

+ (NSString *)getCachedAuthToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *authDate = [defaults objectForKey:kLastAuthDate];
    
    if (!authDate) {
        return nil;
    } else if (authDate) {
        
        NSComparisonResult result;
        result = [[NSDate date]
                  compare:[authDate dateByAddingTimeInterval:60 * 60 * 24 * 7]];
        
        if (result == NSOrderedDescending) {
            return nil;
        }
    }
    
    return [defaults objectForKey:kAuthToken];
}

+ (void)cacheUsername:(NSString *)username {
    [UserDataManager cacheObject:username forKey:kUsername];
}

+ (void)cacheTeam:(CLATeam *)team {
    NSDictionary *teamDictionary = @{ kTeamName: team.name, kTeamKey : team.key };
    [UserDataManager cacheObject:teamDictionary forKey:kTeam];
}

+ (NSString *)getUsername {
    return (NSString *)[UserDataManager getCachedObjectForKey:kUsername];
}

+ (CLATeam *)getTeam {
    NSDictionary *teamDictionary = (NSDictionary *)[UserDataManager getCachedObjectForKey:kTeam];
    CLATeam *team = [[CLATeam alloc] init];
    team.key = [teamDictionary objectForKey:kTeamKey];
    team.name = [teamDictionary objectForKey:kTeamName];
    return team;
}

+ (NSData *)getCachedDeviceToken {
    return (NSData *)[UserDataManager getCachedObjectForKey:kDeviceToken];
}


+ (NSDate *)getLastRefrershTime {
    return [UserDataManager getLastRefrershTime];
}

+ (void)cacheAuthToken:(NSString *)authToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authToken forKey:kAuthToken];
    [defaults setObject:[NSDate date] forKey:kLastAuthDate];
    [defaults synchronize];
}

+ (void)cacheDeviceToken:(NSData *)deviceToken {
    [UserDataManager cacheObject:deviceToken forKey:kDeviceToken];
}

+ (void)cacheLastRefreshTime {
    [UserDataManager cacheObject: [NSDate date] forKey:kLastRefreshTime];
}

+ (void)signOut {
    [UserDataManager clearCookie];
    [UserDataManager clearCache];
}

+ (void)cacheTaskServiceAuthInfo:(NSDictionary *)data {
    [UserDataManager cacheObject:[data objectForKey:kTaskUsername] forKey:kTaskUsername];
    [UserDataManager cacheObject:[data objectForKey:kTaskUserId] forKey:kTaskUserId];
    [UserDataManager cacheObject:[data objectForKey:kTaskAuthToken] forKey:kTaskAuthToken];
    [UserDataManager cacheObject:[data objectForKey:kTaskAuthExpire] forKey:kTaskAuthExpire];
}

+ (NSString *)getTaskAuthFrameUrl {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *array = @[
                       kTaskServiceRootUrl,
                       kTaskAuthPagePath,
                       @"?userId=",
                       [defaults objectForKey:kTaskUserId],
                       @"&token=",
                       [defaults objectForKey:kTaskAuthToken],
                       @"&expires=",
                       [defaults objectForKey:kTaskAuthExpire],
                       ];
    return [[array componentsJoinedByString:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma Private Methods

+ (void)clearCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defaults dictionaryRepresentation];
    for (NSString *key in dict) {
        // Device Token should be not cleared
        if (![key isEqualToString:kDeviceToken]) {
            [defaults removeObjectForKey:key];
        }
    }
    [defaults synchronize];
}

+ (void)cacheObject:(NSObject *)object forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

+ (id)getCachedObjectForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)clearCookie {
    NSHTTPCookieStorage *cookieStorage =
    [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

@end
