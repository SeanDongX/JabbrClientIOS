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

// Data Model
#import "CLARoom.h"
#import "CLATeamViewModel.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

// View Controller
#import "CLACreateRoomViewController.h"
#import "CLACreateTeamViewController.h"

// Message Client
#import "CLASignalRMessageClient.h"

// Custom Controls
#import "BOZPongRefreshControl.h"
#import "CLATopicDataSource.h"
#import "UserDataManager.h"
#import "CLAChatViewController.h"
#import "slidingViewController.h"

NSString * const kHomeTopicViewCellIdentifierName = @"TopicCell";

@interface CLAHomeTopicViewController ()

@property(nonatomic, strong) CLATopicDataSource *dataSource;

@property(weak, nonatomic) IBOutlet UITableView *topicTableView;
@property(weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;
@property(nonatomic) BOOL isRefreshing;

@end

@implementation CLAHomeTopicViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self subscribNotifications];
}

- (void)viewDidLoad {
    [self initDataSource];
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
        
        self.dataSource.pongRefreshControl = self.pongRefreshControl;
    }
}

- (void)initDataSource {
    self.dataSource = [[CLATopicDataSource alloc] init];
    self.dataSource.slidingViewController = (SlidingViewController *)self.slidingViewController;
    self.dataSource.tableCellIdentifierName = kHomeTopicViewCellIdentifierName;
    self.dataSource.advancedMode = YES;
    self.dataSource.eventDelegate = self;
    
    self.topicTableView.dataSource = self.dataSource;
    self.topicTableView.delegate = self.dataSource;
    
    self.searchBar.delegate = self;
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
        
        NSMutableArray *roomArray = [[teamViewModel.rooms allValues] mutableCopy];
        NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [roomArray sortUsingDescriptors:@[ sortDescriptor ]];
        [self updateRooms:roomArray];
    }
    
    [self.topicTableView reloadData];
    self.welcomeLabel.text =
    [NSString stringWithFormat: NSLocalizedString(@"Welcome to team %@", nil), [UserDataManager getTeam].name];
    [self didFinishRefresh];
}

- (void)updateRooms:(NSArray<CLARoom *> *)rooms {
    [self.dataSource updateRooms:rooms];
    [self.topicTableView reloadData];
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
    [UserDataManager cacheLastRefreshTime];
    self.isRefreshing = TRUE;
    [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
    // team loading finished will be notified through kEventTeamUpdated
    // notification which calls self.updateTeam method
}

- (void)didFinishRefresh {
    
    if (!self.isRefreshing) {
        [self.topicTableView reloadData];
        return;
    }
    
    NSDate *lastRefreshTime = [UserDataManager getLastRefreshTime];
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
#pragma mark - Event Handlers

- (void)showCreateTopicView:(id)sender {
    [self openRoom:nil];
    return;
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
    
    [self.topicTableView reloadData];
}


- (void)openRoom: (CLARoom *)room {
    
    UINavigationController *navController = nil;
    
    navController = [(SlidingViewController *)self.slidingViewController getNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    CLAChatViewController *chatViewController =
    [navController.viewControllers objectAtIndex:0];
    
    [(SlidingViewController *)self.slidingViewController setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    //[navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

@end
