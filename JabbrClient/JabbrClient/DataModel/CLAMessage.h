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
#import "Constants.h"

@interface CLAMessage : RLMObject

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSDate *when;
@property(nonatomic, strong) NSString *fromUserName;
@property(nonatomic, strong) NSNumber<RLMInt> *roomKey;

@property(nonatomic, strong) CLAUser *fromUser;

- (MessageType)getType;

+ (CLAMessage *)copyFromMessage:(CLAMessage *)existingMessage;
+ (NSArray <CLAMessage *> *)getFromDataArray:(NSArray *)dictionaryArray forRoom:(NSNumber *)roomKey;
+ (CLAMessage *)getFromData:(NSDictionary *)messageDictionary forRoom:(NSNumber *)roomKey;

@end

RLM_ARRAY_TYPE(CLAMessage)