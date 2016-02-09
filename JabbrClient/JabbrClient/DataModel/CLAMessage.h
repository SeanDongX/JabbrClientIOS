//
//  CLAMessage.h
//  Collara
//
//  Created by Sean on 09/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface CLAMessage : RLMObject

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSDate *when;
@property(nonatomic, strong) NSString *fromUserName;
@property(nonatomic, strong) NSString *roomName;

+ (CLAMessage *)getFromData:(NSDictionary *)messageDictionary FormRoom:(NSString *)roomName;

@end

RLM_ARRAY_TYPE(CLAMessage)