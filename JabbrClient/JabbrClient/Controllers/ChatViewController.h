//
//  ChatViewController.h
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import "CLAMessage.h"
#import "CLAMessageClient.h"

// Data Models
#import "CLARoom.h"

@interface ChatViewController
: JSQMessagesViewController <CLAMessageClientDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

- (void)setActiveRoom:(CLARoom *)room;
- (void)didReceiveTeams:(NSArray *)userTeams;
- (void)didReceiveMessage:(id<JSQMessageData>)message inRoom:(NSString *)room;
- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room;

- (void)showTaskView;
- (void)showInfoView;
@end
