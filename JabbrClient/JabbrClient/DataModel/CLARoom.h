//
//  CLARoom.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

// Data Models
#import "CLAUser.h"
#import "CLAMessage.h"

@interface CLARoom : RLMObject

@property(nonatomic, strong) NSNumber<RLMInt> *key;
//@property(nonatomic, strong) NSNumber<RLMInt> *teamKey;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic) BOOL isPrivate;
@property(nonatomic) BOOL isDirectRoom;
@property(nonatomic) BOOL closed;
@property(nonatomic) NSInteger unread;
@property(nonatomic, strong)RLMArray<CLAUser *><CLAUser> *users;
@property(nonatomic, strong)RLMArray<CLAUser *><CLAUser> *owners;
@property(nonatomic, strong)RLMArray<CLAMessage *><CLAMessage> *messages;

////TODO: remove messages getter and setter
//- (NSMutableArray <CLAMessageViewModel *> *)messages;
//- (void)setMessages: (NSMutableArray <CLAMessageViewModel *> *)messages;

+ (NSArray <CLARoom *> *)getFromDataArray:(NSArray *)dictionary;
+ (CLARoom *)getFromData:(NSDictionary *)dictionary;
- (NSString *)getHandle;

@end

RLM_ARRAY_TYPE(CLARoom)