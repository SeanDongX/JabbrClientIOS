//
//  CLAUser.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"

typedef enum {
    CLAUserStatusActive,
    CLAUserStatusInactive,
    CLAUserStatusOffline
} CLAUserStatus;


GENERICSABLE(CLAUser)

@interface CLAUser : NSObject<CLAUser>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLAUserStatus status;

- (BOOL)isCurrentUser;
+ (CLAUser *)getFromData:(NSDictionary *)userDictionary;

@end
