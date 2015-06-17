//
//  CLAHomeMemberViewController.m
//  Collara
//
//  Created by Sean on 01/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeMemberViewController.h"

//Util
#import "Constants.h"
#import "CLAWebApiClient.h"
#import "AuthManager.h"
#import "MBProgressHUD.h"
#import "CLAToastManager.h"
#import "CLASignalRMessageClient.h"
#import "CLAUtility.h"
//Data Model
#import "CLAUser.h"
#import "CLATeamViewModel.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

//View Controller
#import "CLACreateRoomViewController.h"

@interface CLAHomeMemberViewController ()

@property (weak, nonatomic) IBOutlet UITableView *teamMemberTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) BOOL isFiltered;

@property (strong, nonatomic) NSArray<CLAUser> *users;
@property (strong, nonatomic) NSArray<CLAUser> *filteredUsers;

@end

@implementation CLAHomeMemberViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self subscribNotifications];
}

- (void)viewDidLoad {
    self.searchBar.delegate = self;
}

- (void)dealloc {
    [self unsubscribNotifications];
}

#pragma mark -
#pragma mark Notifications
- (void)subscribNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTeam:) name:kEventTeamUpdated object:nil];
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTeam:(NSNotification *)notification {
    CLATeamViewModel *teamViewModel = [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
    
    if (teamViewModel != nil) {
        [self updateTeamMembers:teamViewModel.users];
    }
}

- (void)updateTeamMembers: (NSArray *)users {
    if (users != nil) {
        self.users = users;
        [self.teamMemberTableView reloadData];
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return NSLocalizedString(@"Members", nil);
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self getTeamMemberCount];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamMemberCell"];
    CLAUser *user = [self getUserAtRow:indexPath.row];
    cell.textLabel.text = [user getHandle];
    
    cell.textLabel.textColor = [Constants mainThemeContrastColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants highlightColor];
    cell.selectedBackgroundView = backgroundView;
    
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
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 250, 30)];
    title.textColor = [UIColor whiteColor];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor: [Constants tableHeaderColor]];
    
    [headerView addSubview:title];
    
    title.text = [NSString stringWithFormat: NSLocalizedString(@"Team members (%@)", nil), [self getTeamMemberCountString]];

    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 10, 30, 30)];
    [addButton addTarget:self action:@selector(shareInvite) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    [headerView addSubview:addButton];
    
    return headerView;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma Search Bar Delegate Methods

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = FALSE;
    }
    else
    {
        self.isFiltered = TRUE;
        [self filterContentForSearchText:text];
    }
    
    [self.teamMemberTableView reloadData];
}


#pragma mark -
#pragma mark Private Methods

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.filteredUsers = [self.users filteredArrayUsingPredicate:resultPredicate];
}

- (CLAUser *)getUserAtRow:(NSInteger)row {
    if (self.isFiltered) {
        return [self.filteredUsers objectAtIndex:row];
    } else {
        return [self.users objectAtIndex:row];
    }
}

- (void)showCreateTopicView {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    createRoomViewController.slidingMenuViewController = (SlidingViewController *)self.slidingViewController;
    [self presentViewController:createRoomViewController animated:YES completion:nil];
}

- (NSUInteger)getTeamMemberCount {
    if (self.isFiltered) {
        return self.filteredUsers == nil ? 0 : self.filteredUsers.count;
    }
    else {
        return self.users == nil ? 0 : self.users.count;
    }
}

- (NSString *)getTeamMemberCountString {
    NSUInteger filterCount = self.filteredUsers == nil ? 0 : self.filteredUsers.count;
    NSUInteger totalCount = self.users == nil ? 0 : self.users.count;
    
    if (self.isFiltered) {
        return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)filterCount, (unsigned long)totalCount];
    }
    else {
        return [NSString stringWithFormat:@"%lu", (unsigned long)totalCount];
    }
}

- (void)shareInvite {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[CLAWebApiClient sharedInstance] getInviteCodeForTeam:[CLAUtility getUserDefault:kTeamKey] completion:^(NSString *invitationCode, NSString *errorMessage) {
        if (errorMessage != nil) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"We are terribly sorry, but some error happened.", nil) completionBlock:nil];
            return;
        }
        
        //TODO: use user full name instead
        CLATeamViewModel *teamViewModel = [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
        
        NSString *teamName = teamViewModel.team.name;
        
        NSString *username = [CLAUtility getUserDefault:kUsername];
        NSString *userFullName = username;
        
        CLAUser *user = [[[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam] findUser:username];
        
        if (user != nil && user.realName != nil){
            userFullName = user.realName;
        }
        
        NSURL *inviteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.collara.co/teams/join/?invitationId=%@", invitationCode]];
        
        //TODO: locale based app download url
        NSURL *appDownloadUrl = [NSURL URLWithString:@"https://itunes.apple.com/app/id983440285"];
        
        NSString *invitationMessage = [NSString stringWithFormat:NSLocalizedString(@"Team invitation message", nil), userFullName, teamName, inviteUrl, invitationCode, appDownloadUrl];
        
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[invitationMessage]
                                          applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
@end
