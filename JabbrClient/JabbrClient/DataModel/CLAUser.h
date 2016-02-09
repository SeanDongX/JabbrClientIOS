//
//  CLAUser.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

typedef enum {
    CLAUserStatusActive,
    CLAUserStatusInactive,
    CLAUserStatusOffline
} CLAUserStatus;

@interface CLAUser : RLMObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *realName;
@property(nonatomic, strong) NSString *initials;
@property(nonatomic, strong) NSString *color;
@property(nonatomic, strong) NSString *email;

@property(nonatomic) CLAUserStatus status;

- (BOOL)isCurrentUser;
- (NSString *)getHandle;
- (UIColor *)getUIColor;

+ (NSString *)getHandle:(NSString *)username;
+ (CLAUser *)getFromData:(NSDictionary *)userDictionary;

@end

RLM_ARRAY_TYPE(CLAUser)