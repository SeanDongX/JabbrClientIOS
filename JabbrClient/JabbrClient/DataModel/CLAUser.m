//
//  CLAUser.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAUser.h"

//Util
#import "Constants.h"
#import "AuthManager.h"
#import "CLAUtility.h"

@implementation CLAUser


- (BOOL)isCurrentUser {
    return [self.name caseInsensitiveCompare:[[AuthManager sharedInstance] getUsername]] == NSOrderedSame;
}


- (NSString*)getHandle {
    return [CLAUser getHandle:self.name];
}

+ (NSString*)getHandle:(NSString *)username {
    return [NSString stringWithFormat:@"%@%@", kUserPrefix, username];
}

+ (CLAUserStatus)getStatus:(NSString *)status {
    if ([CLAUtility isString:status caseInsensitiveEqualTo:@"active"]) {
        return CLAUserStatusActive;
    }
    else if ([CLAUtility isString:status caseInsensitiveEqualTo:@"inactive"]) {
        return CLAUserStatusInactive;
    }
    else {
        return CLAUserStatusOffline;
    }
}

+ (CLAUser *)getFromData:(NSDictionary *)userDictionary {
    CLAUser *user = [[CLAUser alloc] init];
    user.name = [userDictionary objectForKey:@"Name"];
    user.realName = [userDictionary objectForKey:@"RealName"];
    user.status = [self getStatus:[userDictionary objectForKey:@"Status"]];
    return  user;
}

@end
