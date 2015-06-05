//
//  LeftMenuViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "LeftMenuViewController.h"

//Util
#import "DemoData.h"
#import "ChatThread+Category.h"
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

@property (nonatomic, strong) NSArray<ChatThread> *chatThreads;

@property (nonatomic, strong) NSArray<ChatThread> *filteredChatThreads;

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
    [self updateChatThreads:self.chatThreads];
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
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTeam: (NSNotification *)notification {
    CLATeamViewModel *teamViewModel = [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
    if (teamViewModel != nil) {
        
        NSMutableArray *chatThreadArray = [NSMutableArray array];
        for (CLARoom *room in teamViewModel.rooms) {
            
            if (room.users != nil && room.users.count > 0) {
            
                for (CLAUser *user in room.users) {
                    if ([user isCurrentUser] != NO) {
                        //only show my topics
                        ChatThread *thread= [[ChatThread alloc] init];
                        thread.title = room.name;
                        [chatThreadArray addObject:thread];
                        
                        break;
                    }
                        
                }
            }
        }
        
        [self updateChatThreads:chatThreadArray];
    }
}

#pragma mark -
#pragma mark - Public Methods

- (void)updateChatThreads:(NSArray *)chatThreads {
    
    //Find current selected
    NSInteger currentSelected = -1;
    NSString *selectedChatTitle = nil;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        currentSelected = selectedIndexPath.row;
    }
    
    if (self.chatThreads != nil && self.chatThreads.count > currentSelected) {
        ChatThread *selectedChatThrad = [self.chatThreads objectAtIndex:currentSelected];
        selectedChatTitle = selectedChatThrad.title;
    }
    
    //Update threads array and table view
    self.chatThreads = chatThreads;
    [self.tableView reloadData];
    
    //select last selected, if any
    [self selectRoom:selectedChatTitle closeMenu:NO];
}

- (void)selectRoom: (NSString *)room closeMenu:(BOOL)close {
    //TODO: support section
    if (room == nil)
    {
        return;
    }
    
    [self.tableView reloadData];
    
    for (int key=0 ; key< self.chatThreads.count; key++) {
        ChatThread *thread = [self.chatThreads objectAtIndex:key];
        
        if ([thread.title isEqualToString: room]) {
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
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ChatThread *chatThread = [self getChatThreadAtRow:indexPath.row];
    cell.textLabel.text = [chatThread getDisplayTitle];

    cell.textLabel.textColor = [UIColor whiteColor];
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
        [chatViewController switchToChatThread:[self getChatThreadAtRow:indexPath.row]];
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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.filteredChatThreads = [self.chatThreads filteredArrayUsingPredicate:resultPredicate];
}

- (ChatThread *)getChatThreadAtRow:(NSInteger)row {
    if (self.isFiltered) {
        return [self.filteredChatThreads objectAtIndex:row];
    } else {
        return [self.chatThreads objectAtIndex:row];
    }
}

- (NSUInteger)getRoomCount {
    if (self.isFiltered) {
        return self.filteredChatThreads == nil ? 0 : self.filteredChatThreads.count;
    }
    else {
        return self.chatThreads == nil ? 0 : self.chatThreads.count;
    }
}

- (NSString *)getRoomCountString {
    NSUInteger filterCount = self.filteredChatThreads == nil ? 0 : self.filteredChatThreads.count;
    NSUInteger totalCount = self.chatThreads == nil ? 0 : self.chatThreads.count;
    
    if (self.isFiltered) {
        return [NSString stringWithFormat:@"%lu/%lu", (unsigned long)filterCount, (unsigned long)totalCount];
    }
    else {
        return [NSString stringWithFormat:@"%lu", (unsigned long)totalCount];
    }
}

@end
