//
//  ChatViewController.h
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"

@interface ChatViewController : UIViewController <UISplitViewControllerDelegate, SRConnectionDelegate>

@property (nonatomic, strong) SRHubConnection *connection;
@property (nonatomic, strong) SRHubProxy *hub;
@property (nonatomic, strong) NSMutableArray *messagesReceived;

@property (nonatomic, strong) IBOutlet UITableView *messageTable;
@property (nonatomic, strong) IBOutlet UITextField *messageField;

//@property (nonatomic, strong) IBOutlet UITableView *messageTable;

//- (IBAction)connectClicked:(id)sender;
- (IBAction)sendClicked:(id)sender;
- (IBAction)menuButtonTapped:(id)sender;
- (IBAction)reconnectButtonTapped:(id)sender;
@end
