//
//  CLAUser.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CLAUserStatusActive,
    CLAUserStatusInactive,
    CLAUserStatusOffline
} CLAUserStatus;

@interface CLAUser : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *realName;
@property(nonatomic) CLAUserStatus status;

- (BOOL)isCurrentUser;
- (NSString *)getHandle;

+ (NSString *)getHandle:(NSString *)username;
+ (CLAUser *)getFromData:(NSDictionary *)userDictionary;

@end
