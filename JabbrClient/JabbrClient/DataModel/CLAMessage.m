//
//  CLAMessage.m
//  JabbrClient
//
//  Created by Sean on 07/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "CLAMessage.h"

@implementation CLAMessage


- (instancetype)initWithMessageId:(NSString *)messageId
                        SenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                             text:(NSString *)text {

    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    _messageId = messageId;
    
    return self;
}

//TODO: add more init methods from JSQMessage
@end
