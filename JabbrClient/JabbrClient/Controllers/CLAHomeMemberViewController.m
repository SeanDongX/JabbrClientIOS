//
//  CLAHomeMemberViewController.m
//  Collara
//
//  Created by Sean on 01/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeMemberViewController.h"

// Util
#import "Constants.h"
#import "CLAWebApiClient.h"
#import "UserDataManager.h"
#import "CLANotificationManager.h"
#import "CLASignalRMessageClient.h"

// Data Model
#import "CLAUser.h"
#import "CLATeamViewModel.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

// View Controller
#import "CLACreateRoomViewController.h"

// Custom Controls
#import "BOZPongRefreshControl.h"
#import "CLATaskWebViewController.h"

#import "Masonry.h"

@interface CLAHomeMemberViewController ()

@property(weak, nonatomic) IBOutlet UITableView *teamMemberTableView;
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic) BOOL isFiltered;

@property(strong, nonatomic) NSArray<CLAUser *> *users;
@property(strong, nonatomic) NSArray<CLAUser *> *filteredUsers;

@property(nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;
@property(nonatomic) BOOL isRefreshing;

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

- (void)viewDidLayoutSubviews {
    // The very first time this is called, the table view has a smaller size than
    // the screen size
    if (self.teamMemberTableView.frame.size.width >=
        [UIScreen mainScreen].bounds.size.width) {
        self.pongRefreshControl =
        [BOZPongRefreshControl attachToTableView:self.teamMemberTableView
                               withRefreshTarget:self
                                andRefreshAction:@selector(refreshTriggered)];
        self.pongRefreshControl.backgroundColor = [Constants highlightColor];
    }
}

#pragma mark -
#pragma mark Notifications
- (void)subscribNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTeam:)
                                                 name:kEventTeamUpdated
                                               object:nil];
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTeam:(NSNotification *)notification {
    CLATeamViewModel *teamViewModel =
    [[CLASignalRMessageClient sharedInstance].dataRepository getCurrentOrDefaultTeam];
    
    if (teamViewModel != nil) {
        [self updateTeamMembers:teamViewModel.users];
    }
    
    [self didFinishRefresh];
}

- (void)updateTeamMembers:(NSArray *)users {
    if (users != nil) {
        self.users = users;
        [self.teamMemberTableView reloadData];
    }
}

#pragma mark -
#pragma mark - Pull To Resfresh

- (void)refreshTriggered {
    [UserDataManager cacheLastRefreshTime];
    self.isRefreshing = TRUE;
    [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
    // team loading finished will be notified through kEventTeamUpdated
    // notification which calls self.updateTeam method
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.pongRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    [self.pongRefreshControl scrollViewDidEndDragging];
}

- (void)didFinishRefresh {
    
    if (!self.isRefreshing) {
        return;
    }
    
    NSDate *lastRefreshTime = (NSDate *)[UserDataManager getCachedObjectForKey:kLastRefreshTime];
    NSTimeInterval remainTime = 0;
    
    if (![lastRefreshTime isEqual:[NSNull null]]) {
        remainTime = minRefreshLoadTime + [lastRefreshTime timeIntervalSinceNow];
        remainTime =
        remainTime > minRefreshLoadTime ? minRefreshLoadTime : remainTime;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:remainTime
                                     target:self
                                   selector:@selector(finishRefresh)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)finishRefresh {
    [self.pongRefreshControl finishedLoading];
    self.isRefreshing = FALSE;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

- (NSString *)titleForPagerTabStripViewController:
(XLPagerTabStripViewController *)pagerTabStripViewController {
    return NSLocalizedString(@"Members", nil);
}

- (UIColor *)colorForPagerTabStripViewController:
(XLPagerTabStripViewController *)pagerTabStripViewController {
    return [UIColor whiteColor];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self getTeamMemberCount];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger userImageViewTag = 1;
    NSInteger nameLabelTag = 2;
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"TeamMemberCell"];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants highlightColor];
    cell.selectedBackgroundView = backgroundView;
    
    CLAUser *user = [self getUserAtRow:indexPath.row];
    
    UIImage *userImage = [JSQMessagesAvatarImageFactory
                          avatarImageWithUserInitials:user.initials
                          backgroundColor: [user getUIColor]
                          textColor:[UIColor whiteColor]
                          font:[UIFont systemFontOfSize:13.0f]
                          diameter:30].avatarImage;
    
    UIImageView *userImageView =  (UIImageView *)[cell viewWithTag:userImageViewTag];
    if (!userImageView) {
        userImageView = [[UIImageView alloc] initWithImage:userImage];
        [cell.contentView addSubview:userImageView];
        
        [userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left).with.offset(10);
            make.centerY.equalTo(cell.contentView.mas_centerY);
            make.width.equalTo(@30);
            make.height.equalTo(@30);
        }];
    }
    userImageView.image = userImage;
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:nameLabelTag];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        [cell.contentView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left).with.offset(50);
            make.centerY.equalTo(cell.contentView.mas_centerY);
            make.right.equalTo(cell.contentView.mas_right).with.offset(10);
            make.height.equalTo(cell.contentView.mas_height).with.multipliedBy(0.8);
        }];
        nameLabel.textColor = [Constants mainThemeContrastColor];
    }
    
    nameLabel.text = [user getHandle];
    
    return cell;
}

#pragma mark - Table Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = tableView.frame;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 250, 30)];
    title.textColor = [Constants mainThemeContrastColor];
    
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor:[Constants backgroundColor]];
    
    [headerView addSubview:title];
    
    title.text =
    [NSString stringWithFormat:NSLocalizedString(@"Team members (%@)", nil),
     [self getTeamMemberCountString]];
    
    UIButton *addButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(frame.size.width - 60, 10, 30, 30)];
    [addButton addTarget:self
                  action:@selector(shareInvite)
        forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    [headerView addSubview:addButton];
    
    return headerView;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma Search Bar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    if (text.length == 0) {
        self.isFiltered = FALSE;
    } else {
        self.isFiltered = TRUE;
        [self filterContentForSearchText:text];
    }
    
    [self.teamMemberTableView reloadData];
}

#pragma mark -
#pragma mark Private Methods

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate =
    [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
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
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kMainStoryBoard bundle:nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard
                                                             instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    [self presentViewController:createRoomViewController
                       animated:YES
                     completion:nil];
}

- (NSUInteger)getTeamMemberCount {
    if (self.isFiltered) {
        return self.filteredUsers == nil ? 0 : self.filteredUsers.count;
    } else {
        return self.users == nil ? 0 : self.users.count;
    }
}

- (NSString *)getTeamMemberCountString {
    NSUInteger filterCount =
    self.filteredUsers == nil ? 0 : self.filteredUsers.count;
    NSUInteger totalCount = self.users == nil ? 0 : self.users.count;
    
    if (self.isFiltered) {
        return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)filterCount,
                (unsigned long)totalCount];
    } else {
        return [NSString stringWithFormat:@"%lu", (unsigned long)totalCount];
    }
}

- (void)shareInvite {
    
    NSString *inviteCode = [UserDataManager getCachedObjectForKey:kInviteCode];
    if (inviteCode != nil) {
        [self showInvite:inviteCode];
        return;
    }
    
    [CLANotificationManager dismiss];
    
    [[CLAWebApiClient sharedInstance]
     getInviteCodeForTeam:[UserDataManager getTeam].key
     completion:^(NSString *invitationCode, NSString *errorMessage) {
         
         if (errorMessage != nil) {
             [CLANotificationManager
              showText:NSLocalizedString(@"We are terribly "
                                         @"sorry, but some "
                                         @"error happened.",
                                         nil)
              forViewController:self
              withType:CLANotificationTypeError];
             return;
         }
         
         [UserDataManager cacheObject:invitationCode forKey:kInviteCode];
         [self showInvite:invitationCode];
     }];
}

- (void)showInvite:(NSString *)invitationCode {
    // TODO: use user full name instead
    CLATeamViewModel *teamViewModel =
    [[CLASignalRMessageClient sharedInstance].dataRepository getCurrentOrDefaultTeam];
    
    NSString *teamName = teamViewModel.team.name;
    
    NSString *username = [UserDataManager getUsername];
    NSString *userFullName = username;
    
    CLAUser *user =
    [[[CLASignalRMessageClient sharedInstance].dataRepository getCurrentOrDefaultTeam]
     findUser:username];
    
    if (user != nil && user.realName != nil) {
        userFullName = user.realName;
    }
    
    NSURL *inviteUrl = [NSURL
                        URLWithString:[NSString stringWithFormat:@"http://www.collara.co/teams/"
                                       @"join/?invitationId=%@",
                                       invitationCode]];
    
    // TODO: locale based app download url
    NSURL *appDownloadUrl =
    [NSURL URLWithString:@"https://itunes.apple.com/app/id983440285"];
    
    NSString *invitationMessage = [NSString
                                   stringWithFormat:NSLocalizedString(@"Team invitation message", nil),
                                   userFullName, teamName, inviteUrl, invitationCode,
                                   appDownloadUrl];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[ invitationMessage ]
     applicationActivities:nil];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];
}

@end
