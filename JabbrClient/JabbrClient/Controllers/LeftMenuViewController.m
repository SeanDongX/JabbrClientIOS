//
//  LeftMenuViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "LeftMenuViewController.h"

// Util
#import "Constants.h"
#import "CLAUtility.h"
#import "DateTools.h"

// Data Model
#import "CLATeamViewModel.h"
#import "CLARoom.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

// Control
#import "CLARoundFrameButton.h"

// Message Client
#import "CLASignalRMessageClient.h"

// View Controller
#import "ChatViewController.h"
#import "CLACreateRoomViewController.h"

// Custom Controls
#import "BOZPongRefreshControl.h"

@interface LeftMenuViewController ()
@property(nonatomic, strong) CLARoom *selectedRoom;

@property(nonatomic, strong) NSArray<CLARoom> *rooms;
@property(nonatomic, strong) NSMutableDictionary *roomDictionary;
@property(nonatomic, strong) NSMutableDictionary *filteredRoomDictionary;

@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic) BOOL isFiltered;

@property(weak, nonatomic) IBOutlet UIImageView *settingsIcon;
@property(weak, nonatomic) IBOutlet UIButton *settingsButton;
@property(weak, nonatomic) IBOutlet UIImageView *homeIcon;
@property(weak, nonatomic) IBOutlet UIButton *homeButton;

@property(nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;
@property(nonatomic) BOOL isRefreshing;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupMenu];
    [self setupBottomMenus];
    [self subscribNotifications];
    self.searchBar.delegate = self;
    [[UITextField appearanceWhenContainedIn:[LeftMenuViewController class], nil]
     setDefaultTextAttributes:@{
                                NSForegroundColorAttributeName : [UIColor whiteColor]
                                }];
    
    [self.view setBackgroundColor:[Constants mainThemeContrastColor]];
}

- (void)dealloc {
    [self unsubscribNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateRooms:self.rooms];
    self.searchBar.text = nil;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self selectTableViewRowForRoom:self.selectedRoom];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLayoutSubviews {
    self.pongRefreshControl =
    [BOZPongRefreshControl attachToTableView:self.tableView
                           withRefreshTarget:self
                            andRefreshAction:@selector(refreshTriggered)];
    self.pongRefreshControl.backgroundColor = [Constants highlightColor];
}

- (void)initData {
    self.roomDictionary = [NSMutableDictionary dictionary];
    self.filteredRoomDictionary = [NSMutableDictionary dictionary];
}

- (void)setupMenu {
    
    self.slidingViewController.topViewAnchoredGesture =
    ECSlidingViewControllerAnchoredGestureTapping |
    ECSlidingViewControllerAnchoredGesturePanning;
    
    self.slidingViewController.anchorLeftPeekAmount = 50.0;
    self.slidingViewController.anchorRightPeekAmount = 50.0;
}

- (void)setupBottomMenus {
    [self.homeIcon setImage:[Constants homeImage]];
    self.homeButton.contentHorizontalAlignment =
    UIControlContentHorizontalAlignmentLeft;
    
    [self.settingsIcon setImage:[Constants settingsImage]];
    self.settingsButton.contentHorizontalAlignment =
    UIControlContentHorizontalAlignmentLeft;
}

#pragma mark - Properties

- (NSMutableDictionary *)controllers {
    SlidingViewController *slidingViewConroller =
    (SlidingViewController *)self.slidingViewController;
    if (slidingViewConroller != nil) {
        return slidingViewConroller.mainViewControllersCache;
    }
    
    NSLog(@"Error: no main view controllers found in sliding view controller");
    return nil;
}

#pragma mark -
#pragma mark Notifications
- (void)subscribNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTeam:)
                                                 name:kEventTeamUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUnread:)
                                                 name:kEventReceiveUnread
                                               object:nil];
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTeam:(NSNotification *)notification {
    CLATeamViewModel *teamViewModel =
    [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
    if (teamViewModel != nil) {
        
        NSMutableArray *roomArray = [teamViewModel getJoinedRooms];
        NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [roomArray sortUsingDescriptors:@[ sortDescriptor ]];
        [self updateRooms:roomArray];
    }
    
    [self.tableView reloadData];
    [self didFinishRefresh];
}

- (void)receiveUnread:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Public Methods

- (void)selectRoom:(CLARoom *)room closeMenu:(BOOL)close {
    
    if (room == nil) {
        return;
    }
    
    [self.tableView reloadData];
    if (close != NO) {
        [self openRoom:room];
    }
    
    self.selectedRoom = room;
    [self selectTableViewRowForRoom:room];
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
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
        case 2:
            return [self getRoomCountAtSection:section filterCount:YES];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLARoom *room = [self getRoom:indexPath];
    
    if (room == nil) {
        return nil;
    }
    
    BOOL unreadHidden = room.unread <= 0;
    NSString *counterText =
    room.unread > 99 ? @"99+" :[@(room.unread)stringValue];
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    cell.textLabel.text = [room getHandle];
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants highlightColor];
    cell.selectedBackgroundView = backgroundView;
    
    UIView *unreadView = [cell.contentView viewWithTag:1];
    unreadView.hidden = unreadHidden;
    unreadView.backgroundColor = [Constants warningColor];
    unreadView.layer.cornerRadius = 8;
    unreadView.layer.masksToBounds = YES;
    
    UILabel *unreadLabel = (UILabel *)[cell.contentView viewWithTag:2];
    unreadLabel.text = counterText;
    
    return cell;
}

#pragma mark - Table Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = tableView.frame;
    
    UILabel *title = [[UILabel alloc]
                      initWithFrame:CGRectMake(15, 10, frame.size.width - 15 - 60, 30)];
    
    title.text = [self getSectionHeaderString:section];
    title.textColor = [UIColor whiteColor];
    
    UIButton *addButton = [[UIButton alloc]
                           initWithFrame:CGRectMake(frame.size.width - 60, 10, 30, 30)];
    addButton.tag = section;
    
    [addButton addTarget:self
                  action:@selector(showCreateTopicView:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor:[Constants warningColor]];
    
    [headerView addSubview:title];
    [headerView addSubview:addButton];
    
    return headerView;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This undoes the Zoom Transition's scale because it affects the other
    // transitions.
    // You normally wouldn't need to do anything like this, but we're changing
    // transitions
    // dynamically so everything needs to start in a consistent state.
    CLARoom *room = [self getRoom:indexPath];
    if (room != nil) {
        self.selectedRoom = room;
        [self openRoom: room];
    }
}

#pragma mark -
#pragma mark - Event Handlers

- (void)showCreateTopicView:(id)sender {
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kMainStoryBoard bundle:nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard
                                                             instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    UIButton *senderButton = sender;
    if (senderButton != nil) {
        switch (senderButton.tag) {
            case 0:
                createRoomViewController.roomType = RoomTypePulbic;
                break;
                
            case 1:
                createRoomViewController.roomType = RoomTypePrivate;
                break;
                
            case 2:
                createRoomViewController.roomType = RoomTypeDirect;
                break;
            default:
                break;
        }
    }
    
    [self presentViewController:createRoomViewController
                       animated:YES
                     completion:nil];
}

- (IBAction)homeBUttonClicked:(id)sender {
    UINavigationController *navController = [(
                                              (SlidingViewController *)self.slidingViewController)
                                             setTopNavigationControllerWithKeyIdentifier:kHomeNavigationController];
    
    [navController.view
     addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (IBAction)settingsButtonClicked:(id)sender {
    UINavigationController *navController = [(
                                              (SlidingViewController *)self.slidingViewController)
                                             setTopNavigationControllerWithKeyIdentifier:kProfileNavigationController];
    
    [navController.view
     addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

#pragma mark -
#pragma Search Bar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    if (text.length == 0) {
        self.isFiltered = NO;
        [self resetFilter];
    } else {
        self.isFiltered = YES;
        [self filterContentForSearchText:text];
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Private Methods

- (void)selectTableViewRowForRoom:(CLARoom *)room {
    NSIndexPath *indexPath = [self getIndexPath:room];
    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)updateRooms:(NSArray<CLARoom> *)rooms {
    [self.roomDictionary removeAllObjects];
    
    NSPredicate *publicRoomRredicate =
    [NSPredicate predicateWithFormat:@"(isPrivate == %@)", @NO];
    NSArray *publicRooms =
    [rooms filteredArrayUsingPredicate:publicRoomRredicate];
    
    NSPredicate *privateRoomRredicate = [NSPredicate
                                         predicateWithFormat:@"(isPrivate == %@) AND (isDirectRoom == %@)", @YES,
                                         @NO];
    NSArray *privateRooms =
    [rooms filteredArrayUsingPredicate:privateRoomRredicate];
    
    NSPredicate *directRoomRredicate =
    [NSPredicate predicateWithFormat:@"(isDirectRoom == %@)", @YES];
    NSArray *directRooms =
    [rooms filteredArrayUsingPredicate:directRoomRredicate];
    
    [self.roomDictionary
     setObject:publicRooms == nil ?[NSArray array] : publicRooms
     forKey:@"0"];
    [self.roomDictionary
     setObject:privateRooms == nil ?[NSArray array] : privateRooms
     forKey:@"1"];
    [self.roomDictionary
     setObject:directRooms == nil ?[NSArray array] : directRooms
     forKey:@"2"];
    
    [self resetFilter];
    
    self.rooms = rooms;
    [self.tableView reloadData];
}

- (void)resetFilter {
    [self.filteredRoomDictionary
     setObject:[self.roomDictionary objectForKey:@"0"]
     forKey:@"0"];
    [self.filteredRoomDictionary
     setObject:[self.roomDictionary objectForKey:@"1"]
     forKey:@"1"];
    [self.filteredRoomDictionary
     setObject:[self.roomDictionary objectForKey:@"2"]
     forKey:@"2"];
}

- (void)selectRoomName:(NSString *)name closeMenu:(BOOL)close {
    for (CLARoom *room in self.rooms) {
        if ([room.name isEqualToString:name]) {
            [self selectRoom:room closeMenu:close];
            return;
        }
    }
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *searchPredicate = [NSPredicate
                                    predicateWithFormat:@"displayName contains[c] %@", searchText];
    
    for (NSString *key in self.roomDictionary.allKeys) {
        NSArray *rooms = [self.roomDictionary objectForKey:key];
        NSArray *filteredRooms =
        [rooms filteredArrayUsingPredicate:searchPredicate];
        [self.filteredRoomDictionary setObject:filteredRooms forKey:key];
    }
}

- (CLARoom *)getRoom:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.section];
    NSArray *roomArray = [[self getCurrentRoomDictionary] objectForKey:key];
    return roomArray == nil ? nil :[roomArray objectAtIndex:indexPath.row];
}

- (NSIndexPath *)getIndexPath:(CLARoom *)room {
    NSInteger section = 0;
    if (room.isDirectRoom != NO) {
        section = 2;
    } else if (room.isPrivate != NO && room.isDirectRoom == NO) {
        section = 1;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)section];
    NSArray *roomArray = [[self getCurrentRoomDictionary] objectForKey:key];
    
    if (roomArray == nil) {
        return nil;
    }
    
    for (NSInteger k = 0; k < roomArray.count; k++ ) {
        CLARoom *sectionRoom = [roomArray objectAtIndex:k];
        if ([sectionRoom.name isEqualToString:room.name]) {
            return [NSIndexPath indexPathForRow:k inSection:section];
        }
    }
    
    return nil;
}

- (NSUInteger)getRoomCountAtSection:(NSInteger *)section filterCount:(BOOL)filtered {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)section];
    NSArray *targetArray;
    
    if (filtered == NO) {
        targetArray = [self.roomDictionary objectForKey:key];
    }
    else {
        targetArray = [self.filteredRoomDictionary objectForKey:key];
    }
    
    return targetArray == nil ? 0 : targetArray.count;
}

- (NSString *)getSectionHeaderString:(NSInteger)section {
    NSString *count = [self getRoomCountStringAtSection:section];
    
    switch (section) {
        case 0:
            return [NSString
                    stringWithFormat:NSLocalizedString(@"Public Topics (%@)", nil), count];
            
        case 1:
            return [NSString
                    stringWithFormat:NSLocalizedString(@"Private Topics (%@)", nil), count];
            
        case 2:
            return [NSString
                    stringWithFormat:NSLocalizedString(@"Direct Messages (%@)", nil),
                    count];
            
        default:
            return @"";
    }
}

- (NSString *)getRoomCountStringAtSection:(NSInteger)section {
    NSInteger originalCount = [self getRoomCountAtSection:section filterCount:NO];
    
    if (self.isFiltered != NO)
    {
        NSInteger filteredCount = [self getRoomCountAtSection:section filterCount:YES];
        return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)filteredCount, (unsigned long)originalCount];
    } else {
        return [NSString stringWithFormat:@"%lu", (unsigned long)originalCount];
    }
}

- (NSDictionary *)getCurrentRoomDictionary {
    return self.filteredRoomDictionary;
}

- (void)setRoom:(NSString *)roomName withUnread:(NSInteger)count {
    for (CLARoom *room in self.rooms) {
        if ([room.name isEqual:roomName]) {
            room.unread = count;
            return;
        }
    }
}


- (void)openRoom: (CLARoom *)room {
    self.slidingViewController.topViewController.view.layer.transform =
    CATransform3DMakeScale(1, 1, 1);
    
    UINavigationController *navController = nil;
    
    navController = [((SlidingViewController *)self.slidingViewController)
                     getNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    ChatViewController *chatViewController =
    [navController.viewControllers objectAtIndex:0];
    
    [((SlidingViewController *)self.slidingViewController)
     setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    if (chatViewController != nil) {
        [self setRoom:room.name withUnread:0];
        [chatViewController setActiveRoom:room];
    }
    
    [navController.view
     addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

@end
