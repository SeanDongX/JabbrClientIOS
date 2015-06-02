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

//Data Model
#import "CLAUser.h"
#import "CLAUser+Category.h"
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
    CLATeamViewModel *teamViewModel = [notification.userInfo objectForKey:kTeamKey];
    
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
    cell.textLabel.text = [user getDisplayName];
    
    cell.textLabel.textColor = [Constants mainThemeContrastColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants mainThemeColor];
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
    
    [headerView setBackgroundColor: [Constants mainThemeContrastFocusColor]];
    
    [headerView addSubview:title];
    
    title.text = [NSString stringWithFormat: NSLocalizedString(@"Team members (%@)", nil), [self getTeamMemberCountString]];

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

@end
