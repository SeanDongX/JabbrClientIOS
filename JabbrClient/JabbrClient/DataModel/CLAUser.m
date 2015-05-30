//
//  CLAUser.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAUser.h"
#import "AuthManager.h"

@implementation CLAUser


- (BOOL)isCurrentUser {
    return [self.name caseInsensitiveCompare:[[AuthManager sharedInstance] getUsername]] == NSOrderedSame;
}

+ (CLAUser *)getFromData:(NSDictionary *)userDictionary {
    CLAUser *user = [[CLAUser alloc] init];
    user.name = [userDictionary objectForKey:@"Name"];
    return  user;
}

@end
