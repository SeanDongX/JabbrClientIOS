//
//  CLAChatInfoViewController.m
//  Collara
//
//  Created by Sean on 02/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAChatInfoViewController.h"
#import "Constants.h"
#import "CLARoomViewModel.h"
#import "CLAUser.h"
#import "CLARoom+Category.h"
#import "CLAMessageClient.h"
#import "CLARoundFrameButton.h"
#import "CLAToastManager.h"

@interface CLAChatInfoViewController()

@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet CLARoundFrameButton *leaveButton;

@end

@implementation CLAChatInfoViewController

- (void)viewDidLoad {
    
    //TODO: thorw if roomViewModel is nil
    
    [super viewDidLoad];
    [self setupNavBar];
    [self initRoomInfo];
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kStatusBarHeight)];
    navBar.barTintColor = [Constants mainThemeColor];
    navBar.translucent = NO;
    navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };

    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Topic Settings";
        [navBar setItems:@[navItem]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.rightBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}

- (void)initRoomInfo {
    
    [self.topicLabel setText:[self.roomViewModel.room getDisplayTitle]];
}

#pragma mark -
#pragma mark - Event Handlers

- (void)closeButtonClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)inviteButtonClicked:(id)sender {
}

- (IBAction)leaveButtonClicked:(id)sender {
    if (self.messageClient != nil) {
        [self.messageClient leaveRoom:self.roomViewModel.room.name];
        [self.leaveButton setEnabled:NO];
        
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"You will not receive message from this topic any more.", nil)completionBlock:nil];
        
        //TODO:make sure user can not send message to room until next join
    }
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomViewModel.users == nil ? 0 : self.roomViewModel.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ParticipantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CLAUser *user = self.roomViewModel.users[indexPath.row];
    
    if (user != nil) {
        cell.textLabel.text = user.name;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
