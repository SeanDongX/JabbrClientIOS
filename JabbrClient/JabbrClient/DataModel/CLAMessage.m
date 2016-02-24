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

- (MessageType)getType {
    NSPredicate *textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"https?:\\/\\/.*\\.(?:png|jpg)"];
    
    if (!self.content || [textTest evaluateWithObject:[self.content lowercaseString]]) {
        return MessageTypeImage;
    }
    
    textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"https?:\\/\\/.*\\.(?:txt|md|js|doc|docx|xsl|xslx|ppt|pptx)"];
    
    if ([textTest evaluateWithObject:[self.content lowercaseString]]) {
        return MessageTypeDocument;
    }
    
    return MessageTypeText;
}

+ (CLAMessage *)copyFromMessage:(CLAMessage *)existingMessage {
    CLAMessage *newMessage = [[CLAMessage alloc] init];
    newMessage.content = existingMessage.content;
    newMessage.when = existingMessage.when;
    newMessage.fromUserName = existingMessage.fromUserName;
    newMessage.roomKey = existingMessage.roomKey;
    newMessage.fromUser = existingMessage.fromUser;
    
    return newMessage;
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
