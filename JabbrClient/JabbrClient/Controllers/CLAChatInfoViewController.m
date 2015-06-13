//
//  CLAChatInfoViewController.m
//  Collara
//
//  Created by Sean on 02/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAChatInfoViewController.h"

//Util
#import "Constants.h"
#import "CLARoundFrameButton.h"
#import "CLAToastManager.h"

//Data Model
#import "CLARoomViewModel.h"
#import "CLAUser.h"

//Message Client
#import "CLAMessageClient.h"

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
    navItem.title =  NSLocalizedString(@"Topic Settings", nil);
        [navBar setItems:@[navItem]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.rightBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}

- (void)initRoomInfo {
    
    [self.topicLabel setText:[self.roomViewModel.room getHandle]];
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
    switch (section) {
        case 0:
            return [self getUserCount];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ParticipantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CLAUser *user = (CLAUser *)self.roomViewModel.users[indexPath.row];
    
    if (user != nil) {
        cell.textLabel.text = [user getHandle];
    }
    
    return cell;
}

#pragma mark - Table Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = tableView.frame;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    title.textColor = [UIColor whiteColor];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor: [Constants tableHeaderColor]];

    [headerView addSubview:title];
    
    title.text = [NSString stringWithFormat: NSLocalizedString(@"Topic participants (%lu)", nil), [self getUserCount]];
    
    return headerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark
#pragma mark Private Methods

- (NSInteger)getUserCount {
    return self.roomViewModel.users == nil ? 0 : self.roomViewModel.users.count;
}

@end
