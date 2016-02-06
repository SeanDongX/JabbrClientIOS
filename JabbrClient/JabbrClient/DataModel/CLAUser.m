//
//  CLAUser.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAUser.h"

// Util
#import "Constants.h"
#import "UserDataManager.h"
#import "CLAUtility.h"
#import "UIColor+HexString.h"

@implementation CLAUser

+ (NSString *)primaryKey {
    return @"name";
}

- (BOOL)isCurrentUser {
    return
    [self.name
     caseInsensitiveCompare:[UserDataManager getUsername]] ==
    NSOrderedSame;
}

- (NSString *)getHandle {
    return [CLAUser getHandle:self.name];
}

- (UIColor *)getUIColor {
    if (self.color && self.color.length == 7) {
        return [UIColor colorWithHexString: self.color];
    }
    
    return [Constants mainThemeColor];
}

+ (NSString *)getHandle:(NSString *)username {
    return [NSString stringWithFormat:@"%@%@", kUserPrefix, username];
}

+ (CLAUserStatus)getStatus:(NSString *)status {
    if ([CLAUtility isString:status caseInsensitiveEqualTo:@"active"]) {
        return CLAUserStatusActive;
    } else if ([CLAUtility isString:status caseInsensitiveEqualTo:@"inactive"]) {
        return CLAUserStatusInactive;
    } else {
        return CLAUserStatusOffline;
    }
}

+ (CLAUser *)getFromData:(NSDictionary *)userDictionary {
    CLAUser *user = [[CLAUser alloc] init];
    user.name = [userDictionary objectForKey:@"Name"];
    user.realName = [userDictionary objectForKey:@"RealName"];
    user.initials = [userDictionary objectForKey:@"Initials"];
    user.color = [userDictionary objectForKey:@"Color"];
    user.email = [userDictionary objectForKey:@"Email"];
    user.status = [self getStatus:[userDictionary objectForKey:@"Status"]];
    return user;
}

@end
