//
//  CLAMessage.m
//  Collara
//
//  Created by Sean on 09/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLAMessage.h"

@implementation CLAMessage

+ (NSString *)primaryKey {
    return @"key";
}

+ (NSArray <CLAMessage *> *)getFromDataArray:(NSArray *)dictionaryArray forRoom:(NSNumber *)roomKey {
    NSMutableArray <CLAMessage *> *messages = [NSMutableArray array];
    if (dictionaryArray && dictionaryArray != [NSNull null] && dictionaryArray.count > 0) {
        for (NSDictionary *dictionary in dictionaryArray) {
            CLAMessage *message = [CLAMessage getFromData:dictionary forRoom:roomKey];
            if (message) {
                [messages addObject:message];
            }
        }
    }
    
    return messages;
}

+ (CLAMessage *)getFromData:(NSDictionary *)messageDictionary forRoom:(NSNumber *)roomKey {
    CLAMessage *message = [[CLAMessage alloc] init];
    
    message.roomKey = roomKey;
    
    NSDictionary *userData = [messageDictionary objectForKey:@"User"];
    NSString *dateString = [messageDictionary objectForKey:@"When"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    message.when = [formatter dateFromString:dateString];
    
    if (userData && [userData objectForKey:@"Name"]) {
        message.fromUserName = [userData objectForKey:@"Name"];
        message.fromUser = [CLAUser getFromData:userData];
    }
    
    message.key = [messageDictionary objectForKey:@"Id"];
    message.content = [messageDictionary objectForKey:@"Content"];
    
    return message;
}

@end
