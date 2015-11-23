//
//  CLAHomeViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeTopicViewController.h"

// Util
#import "Constants.h"
#import "CLAUtility.h"

// Data Model
#import "CLARoom.h"
#import "CLATeamViewModel.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

// View Controller
#import "CLACreateTopicViewController.h"
#import "ChatViewController.h"
#import "CLACreateTeamViewController.h"

// Message Client
#import "CLASignalRMessageClient.h"

// Custom Controls
#import "BOZPongRefreshControl.h"

@interface CLAHomeTopicViewController ()

@property(weak, nonatomic) IBOutlet UITableView *topicTableView;
@property(weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic) BOOL isFiltered;

@property(strong, nonatomic) NSArray<CLARoom> *rooms;
@property(strong, nonatomic) NSArray<CLARoom> *filteredRooms;

@property(nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;
@property(nonatomic) BOOL isRefreshing;

@end

@implementation CLAHomeTopicViewController

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
    if (self.topicTableView.frame.size.width >=
        [UIScreen mainScreen].bounds.size.width) {
        self.pongRefreshControl =
        [BOZPongRefreshControl attachToTableView:self.topicTableView
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
    CLATeamViewModel *teamViewModel = [self getTeam];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"closed == %@", [NSNumber numberWithBool:NO]];
    NSArray<CLARoom> *rooms =
    [[teamViewModel.rooms allValues] filteredArrayUsingPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    self.rooms = [rooms sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    
    if (teamViewModel != nil) {
        [self updateRooms:self.rooms];
        
        if (teamViewModel.team != nil) {
            self.welcomeLabel.text = [NSString
                                      stringWithFormat:NSLocalizedString(@"Welcome to join team %@", nil),
                                      teamViewModel.team.name];
        }
    }
    
    [self didFinishRefresh];
}

- (void)updateRooms:(NSArray<CLARoom> *)rooms {
    if (rooms != nil) {
        [self.topicTableView reloadData];
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

- (NSString *)titleForPagerTabStripViewController:
(XLPagerTabStripViewController *)pagerTabStripViewController {
    return NSLocalizedString(@"Topics", nil);
}

- (UIColor *)colorForPagerTabStripViewController:
(XLPagerTabStripViewController *)pagerTabStripViewController {
    return [UIColor whiteColor];
}

#pragma mark -
#pragma mark - Pull To Resfresh

- (void)refreshTriggered {
    [CLAUtility setUserDefault:[NSDate date] forKey:kLastRefreshTime];
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
        [self.topicTableView reloadData];
        return;
    }
    
    NSDate *lastRefreshTime = [CLAUtility getUserDefault:kLastRefreshTime];
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

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self getRoomCount];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
    
    CLARoom *room = [self getRoomAtRow:indexPath.row];
    cell.textLabel.text = [room getHandle];
    
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

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = tableView.frame;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 250, 30)];
    title.textColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor:[Constants tableHeaderColor]];
    
    [headerView addSubview:title];
    
    title.text =
    [NSString stringWithFormat:NSLocalizedString(@"All Topics (%@)", nil),
     [self getRoomCountString]];
    
    UIButton *addButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(frame.size.width - 60, 10, 30, 30)];
    [addButton addTarget:self
                  action:@selector(showCreateTopicView:)
        forControlEvents:UIControlEventTouchUpInside];
    addButton.tag = section;
    
    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    [headerView addSubview:addButton];
    
    return headerView;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navController = nil;
    
    navController = [((SlidingViewController *)self.slidingViewController)
                     getNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    ChatViewController *chatViewController =
    [navController.viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        chatViewController.room = [self getRoomAtRow:indexPath.row];
    }
    
    [((SlidingViewController *)self.slidingViewController)
     setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    [self.slidingViewController resetTopViewAnimated:YES];
}

#pragma mark -
#pragma mark - Event Handlers

- (void)showCreateTopicView:(id)sender {
    UIButton *senderButton = sender;
    CLACreateTopicViewController *createTopicViewController =
    [[CLACreateTopicViewController alloc] initWithRoomType:senderButton.tag];
    [self presentViewController:createTopicViewController
                       animated:YES
                     completion:nil];
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
    
    [self.topicTableView reloadData];
}

#pragma mark -
#pragma mark Private Methods
- (CLATeamViewModel *)getTeam {
    return
    [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate =
    [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.filteredRooms = [self.rooms filteredArrayUsingPredicate:resultPredicate];
}

- (CLARoom *)getRoomAtRow:(NSInteger)row {
    if (self.isFiltered) {
        return [self.filteredRooms objectAtIndex:row];
    } else {
        return [self.rooms objectAtIndex:row];
    }
}

- (NSUInteger)getRoomCount {
    if (self.isFiltered) {
        return self.filteredRooms == nil ? 0 : self.filteredRooms.count;
    } else {
        return self.rooms == nil ? 0 : self.rooms.count;
    }
}

- (NSString *)getRoomCountString {
    NSUInteger filterCount =
    self.filteredRooms == nil ? 0 : self.filteredRooms.count;
    NSUInteger totalCount = self.rooms == nil ? 0 : self.rooms.count;
    
    if (self.isFiltered) {
        return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)filterCount,
                (unsigned long)totalCount];
    } else {
        return [NSString stringWithFormat:@"%lu", (unsigned long)totalCount];
    }
}
@end
