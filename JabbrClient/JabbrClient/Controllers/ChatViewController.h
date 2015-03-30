//
//  ChatViewController.h
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"
#import "ChatThread.h"
#import <JSQMessagesViewController/JSQMessages.h> 

@interface ChatViewController : JSQMessagesViewController <SRConnectionDelegate>

- (id)initWithChatThread:(ChatThread *)chatThread;
- (void)switchToChatThread:(ChatThread *)chatThread;

@end
