//
//  CLAMessage.h
//  Collara
//
//  Created by Sean on 09/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "CLAUser.h"

@interface CLAMessage : RLMObject

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSDate *when;
@property(nonatomic, strong) NSString *fromUserName;
@property(nonatomic, strong) NSString *roomName;

@property(nonatomic, strong) CLAUser *fromUser;

+ (CLAMessage *)getFromData:(NSDictionary *)messageDictionary forRoom:(NSString *)roomName;

@end

RLM_ARRAY_TYPE(CLAMessage)