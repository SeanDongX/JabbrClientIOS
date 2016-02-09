//
//  CLAChatViewController.m
//  Collara
//
//  Created by Sean on 10/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLAChatViewController.h"
#import "CLASignalRMessageClient.h"
#import "CLARealmRepository.h"

#import "UIViewController+ECSlidingViewController.h"

@interface CLAChatViewController ()

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenuButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *rightMenuButton;

@property(nonatomic, strong) id<CLAMessageClient> messageClient;
@property(nonatomic, strong) id<CLADataRepositoryProtocol> repository;

@property(nonatomic, strong) CLARoom *room;

@end

@implementation CLAChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initMenu];
}

- (void)initData {
    self.repository = [[CLARealmRepository alloc] init];
    self.messageClient = [CLASignalRMessageClient sharedInstance];
    self.messageClient.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = self.room.displayName;
    
    if (self.messageClient == nil || self.messageClient.teamLoaded == FALSE) {
        //[self showHud];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)connect {
    [self.messageClient connect];
    //
    //    self.senderId = self.messageClient.username;
    //    self.senderDisplayName = self.messageClient.username;
}

#pragma mark -
#pragma mark - Menu Setup

- (void)initMenu {
    [self.leftMenuButton setTitle:@""];
    [self.leftMenuButton setWidth:30];
    [self.leftMenuButton setImage:[Constants menuIconImage]];
    self.leftMenuButton.target = self;
    self.leftMenuButton.action = @selector(showLeftMenu);
    
    [self.rightMenuButton setTitle:@""];
    [self.rightMenuButton setWidth:30];
    [self.rightMenuButton setImage:[Constants optionsIconImage]];
    self.rightMenuButton.target = self;
    self.rightMenuButton.action = @selector(showRightMenu);
}

#pragma mark -
#pragma mark - Navigation

- (void)showLeftMenu {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)showRightMenu {
    [self.slidingViewController anchorTopViewToLeftAnimated:YES];
}

#pragma mark -
#pragma mark - Public Methods

- (void)setActiveRoom:(CLARoom *)room {
    self.room = room;
    [self.messageClient joinRoom:room.name];
}

#pragma mark -
#pragma mark - CLAMessageClientDelegate Methods


- (void)didOpenConnection {
}

- (void)didConnectionChnageState:(CLAConnectionState)oldState
                        newState:(CLAConnectionState)newState {
}

- (void)didReceiveTeams:(NSArray *)teams {
}

- (void)didReceiveJoinRoom:(CLARoom *)room andUpdateRoom:(BOOL)update {
}

- (void)didReceiveUpdateRoom:(CLARoom *)room {
}

- (void)didReceiveMessage:(CLAMessage *)message inRoom:(NSString *)room {
}

- (void)didLoadEarlierMessages:(NSArray<CLAMessage *> *)earlierMessages
                        inRoom:(NSString *)room {
}

- (void)didLoadUsers:(NSArray<CLAUser *> *)users inRoom:(NSString *)room {
}

- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room {
}

- (void)reaplceMessageId:(NSString *)tempMessageId
           withMessageId:(NSString *)serverMessageId {
}
@end
