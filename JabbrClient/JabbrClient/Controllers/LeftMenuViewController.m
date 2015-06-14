//
//  LeftMenuViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "LeftMenuViewController.h"

//Util
#import "Constants.h"

//Data Model
#import "CLATeamViewModel.h"
#import "CLARoom.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

//Control
#import "CLARoundFrameButton.h"

//Message Client
#import "CLASignalRMessageClient.h"

//View Controller
#import "ChatViewController.h"
#import "CLACreateRoomViewController.h"

@interface LeftMenuViewController ()

@property (nonatomic, strong) NSArray<CLARoom> *rooms;

@property (nonatomic, strong) NSArray<CLARoom> *filteredChatThreads;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL isFiltered;

@property (weak, nonatomic) IBOutlet UIImageView *settingsIcon;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *homeIcon;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenu];
    [self setupBottomMenus];
    [self subscribNotifications];
    self.searchBar.delegate = self;
    [[UITextField appearanceWhenContainedIn:[LeftMenuViewController class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.view setBackgroundColor:[Constants mainThemeContrastColor]];
}

- (void)dealloc {
    [self unsubscribNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateRooms:self.rooms];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)setupMenu {
    
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    
    self.slidingViewController.anchorLeftPeekAmount  = 50.0;
    self.slidingViewController.anchorRightPeekAmount = 50.0;
}

- (void)setupBottomMenus {
    [self.homeIcon setImage: [Constants homeImage]];
    self.homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self.settingsIcon setImage: [Constants settingsImage]];
    self.settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

#pragma mark - Properties

- (NSMutableDictionary *)controllers {
    SlidingViewController *slidingViewConroller = (SlidingViewController *)self.slidingViewController;
    if (slidingViewConroller != nil) {
        return slidingViewConroller.mainViewControllersCache;
    }
    
    NSLog(@"Error: no main view controllers found in sliding view controller");
    return nil;
}

#pragma mark - 
#pragma mark Notifications
- (void)subscribNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTeam:) name:kEventTeamUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRoom:) name:kEventRoomUpdated object:nil];
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTeam: (NSNotification *)notification {
    CLATeamViewModel *teamViewModel = [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
    if (teamViewModel != nil) {
        
        NSMutableArray *roomArray = [NSMutableArray array];
        for (CLARoom *room in [teamViewModel.rooms allValues]) {
            
            if (room.users != nil && room.users.count > 0) {
            
                for (CLAUser *user in room.users) {
                    if ([user isCurrentUser] != NO) {
                        [roomArray addObject:room];
                        
                        break;
                    }
                        
                }
            }
        }
        
        [self updateRooms:roomArray];
    }
}



- (void)updateRoom:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Public Methods

- (void)updateRooms:(NSArray<CLARoom> *)rooms {
    
    //Find current selected
    NSInteger currentSelected = -1;
    NSString *selectedRoomName = nil;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        currentSelected = selectedIndexPath.row;
    }
    
    if (self.rooms != nil && self.rooms.count > currentSelected) {
        CLARoom *selectedRoom = [self.rooms objectAtIndex:currentSelected];
        selectedRoomName = selectedRoom.name;
    }
    
    //Update room array and table view
    self.rooms = rooms;
    [self.tableView reloadData];
    
    //select last selected, if any
    [self selectRoom:selectedRoomName closeMenu:NO];
}

- (void)selectRoom: (NSString *)room closeMenu:(BOOL)close {
    //TODO: support section
    if (room == nil)
    {
        return;
    }
    
    [self.tableView reloadData];
    
    for (int key=0 ; key< self.rooms.count; key++) {
        CLARoom *thread = [self.rooms objectAtIndex:key];
        
        if ([thread.name isEqualToString: room]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:key inSection:0];
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            
            if (close != NO) {
                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            }
            
            return;
        }
    }
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self getRoomCount];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLARoom *room = [self getRoomAtRow:indexPath.row];
    BOOL unreadHidden = room.unread <= 0;
    NSString *counterText = room.unread > 99 ? @"99+" : [@(room.unread) stringValue];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
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
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = tableView.frame;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    title.text = [NSString stringWithFormat:NSLocalizedString(@"Topics (%@)", nil), [self getRoomCountString]];
    title.textColor = [UIColor whiteColor];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 10, 30, 30)];
    
    [addButton addTarget:self action:@selector(showCreateTopicView) forControlEvents:UIControlEventTouchUpInside];

    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor: [Constants tableHeaderColor]];
    
    [headerView addSubview:title];
    [headerView addSubview:addButton];

    return headerView;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);

    UINavigationController *navController = nil;
        
    navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        CLARoom *room = [self getRoomAtRow:indexPath.row];
        [self setRoom:room.name withUnread:0];
        [chatViewController switchToRoom:room];
    }
    
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}


#pragma mark -
#pragma mark - Event Handlers

- (void)showCreateTopicView {
        
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    createRoomViewController.slidingMenuViewController = (SlidingViewController *)self.slidingViewController;
    [self presentViewController:createRoomViewController animated:YES completion:nil];
}

- (IBAction)homeBUttonClicked:(id)sender {
    UINavigationController *navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kHomeNavigationController];
    
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (IBAction)settingsButtonClicked:(id)sender {
    UINavigationController *navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kProfileNavigationController];
        
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
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
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Private Methods

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.filteredChatThreads = [self.rooms filteredArrayUsingPredicate:resultPredicate];
}

- (CLARoom *)getRoomAtRow:(NSInteger)row {
    if (self.isFiltered) {
        return [self.filteredChatThreads objectAtIndex:row];
    } else {
        return [self.rooms objectAtIndex:row];
    }
}

- (NSUInteger)getRoomCount {
    if (self.isFiltered) {
        return self.filteredChatThreads == nil ? 0 : self.filteredChatThreads.count;
    }
    else {
        return self.rooms == nil ? 0 : self.rooms.count;
    }
}

- (NSString *)getRoomCountString {
    NSUInteger filterCount = self.filteredChatThreads == nil ? 0 : self.filteredChatThreads.count;
    NSUInteger totalCount = self.rooms == nil ? 0 : self.rooms.count;
    
    if (self.isFiltered) {
        return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)filterCount, (unsigned long)totalCount];
    }
    else {
        return [NSString stringWithFormat:@"%lu", (unsigned long)totalCount];
    }
}

- (void)setRoom:(NSString *)roomName withUnread:(NSInteger)count {
    for (CLARoom *room in self.rooms) {
        if ([room.name isEqual:roomName]) {
            room.unread = count;
            return;
        }
    }
}
@end
