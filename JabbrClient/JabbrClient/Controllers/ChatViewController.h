//
//  ChatViewController.h
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"
#import "ChatThread.h"
#import <JSQMessagesViewController/JSQMessages.h> 
#import "CLAMessage.h"
#import "CLAMessageClient.h"

@interface ChatViewController : JSQMessagesViewController <CLAMessageClientDelegate>

@property (strong, nonatomic) NSString *preselectedTitle;

- (void)switchToChatThread:(ChatThread *)chatThread;

- (void)didReceiveTeams: (NSArray *)userTeams;

- (void)didReceiveMessage: (id<JSQMessageData>) message inRoom:(NSString*)room;

- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room;

@end
