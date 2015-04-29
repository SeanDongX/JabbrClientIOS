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
#import "CLAMessage.h"
#import "CLAMessageClient.h"

@interface ChatViewController : JSQMessagesViewController <CLAMessageClientDelegate>

- (void)switchToChatThread:(ChatThread *)chatThread;

- (void)didReceiveUserTeams: (NSArray *)userTeams;

- (void)didReceiveMessage: (id<JSQMessageData>) message inRoom:(NSString*)room;

- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room;

@end
