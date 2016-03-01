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

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

// Control
#import "CLARoundFrameButton.h"

// Message Client
#import "CLASignalRMessageClient.h"
#import "CLACreateRoomViewController.h"

// Custom Controls
#import "CLATopicDataSource.h"
#import "CLAProfileViewController.h"
#import "UserDataManager.h"

NSString * const kLeftMenuViewCellIdentifierName = @"MenuCell";

@interface LeftMenuViewController ()

@property(nonatomic, strong) CLATopicDataSource *dataSource;

@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property(weak, nonatomic) IBOutlet UIImageView *settingsIcon;
@property(weak, nonatomic) IBOutlet UIButton *settingsButton;
@property(weak, nonatomic) IBOutlet UIImageView *homeIcon;
@property(weak, nonatomic) IBOutlet UIButton *homeButton;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    [self setupMenu];
    [self setupBottomMenus];
    [self subscribNotifications];
    [self updateTeam:nil];
    [self setupStyle];
    [self setupPullToRefresh];
}

- (void)dealloc {
    [self unsubscribNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    self.searchBar.text = nil;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self highlightSelectedRoom];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)initDataSource {
    self.dataSource = [[CLATopicDataSource alloc] init];
    
    self.dataSource.slidingViewController = (SlidingViewController *)self.slidingViewController;
    self.dataSource.tableCellIdentifierName = kLeftMenuViewCellIdentifierName;
    
    self.dataSource.rowBackgroundColor = [Constants darkBackgroundColor];
    self.dataSource.rowTextColor = [UIColor whiteColor];
    
    self.dataSource.eventDelegate = self;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    
    self.searchBar.delegate = self;
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

- (void)setupStyle {
    [[UITextField appearanceWhenContainedIn:[LeftMenuViewController class], nil]
     setDefaultTextAttributes:@{
                                NSForegroundColorAttributeName : [UIColor whiteColor]
                                }];
    
    [self.view setBackgroundColor:[Constants mainThemeContrastColor]];
}

- (void)setupPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc]init];
    
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.backgroundColor = [Constants highlightColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
}

#pragma mark -
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
#pragma Search Bar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    if (text.length == 0) {
        self.dataSource.isFiltered = NO;
        [self.dataSource resetFilter];
    } else {
        self.dataSource.isFiltered = YES;
        [self.dataSource filterContentForSearchText:text];
    }
    
    [self.tableView reloadData];
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
    CLATeam *team = [[CLASignalRMessageClient sharedInstance].dataRepository getCurrentOrDefaultTeam];
    
    if (team != nil) {
        NSMutableArray *roomArray = [[team getJoinedRooms] mutableCopy];
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
        [self.dataSource openRoom:room];
    }
    
    self.dataSource.selectedRoom = room;
    [self highlightSelectedRoom];
}

#pragma mark -
#pragma mark - Pull To Resfresh

- (void)refreshTriggered {
    [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
    // team loading finished will be notified through kEventTeamUpdated
    // notification which calls self.updateTeam method
}

- (void)didFinishRefresh {
    [self.refreshControl endRefreshing];
}

- (void)updateRooms:(NSArray<CLARoom *> *)rooms {
    [self.dataSource updateRooms:rooms];
    [self.tableView reloadData];
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
    UINavigationController *navController = [((SlidingViewController *)self.slidingViewController)
                                             setTopNavigationControllerWithKeyIdentifier:kHomeNavigationController];
    
    [navController.view
     addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (IBAction)settingsButtonClicked:(id)sender {
    
    UINavigationController *navController = [((SlidingViewController *)self.slidingViewController)
                                             setTopNavigationControllerWithKeyIdentifier:@"ProfileNavigationController"];
    
    if (navController.viewControllers == nil) {
        CLAProfileViewController *profileView = [[CLAProfileViewController alloc] init];
        navController.viewControllers = @[ profileView ];
    }
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

#pragma mark -
#pragma mark Private Methods

- (void)highlightSelectedRoom {
    NSIndexPath *indexPath = [self.dataSource getSelectedRoomIndexPath];
    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

@end
