//
//  CLAMessage.h
//  JabbrClient
//
//  Created by Sean on 07/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "JSQMessage.h"

@interface CLAMessage : JSQMessage
@property (copy, nonatomic, readonly) NSString* messageId;

- (instancetype)initWithMessageId:(NSString *)messageId
                         SenderId:(NSString *)senderId
                senderDisplayName:(NSString *)senderDisplayName
                             date:(NSDate *)date
                             text:(NSString *)text;
@end
