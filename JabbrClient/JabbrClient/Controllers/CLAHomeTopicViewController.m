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
#import "CLAUtility.h"
#import "CLANotificationManager.h"

NSString * const kHomeTopicViewCellIdentifierName = @"TopicCell";

@interface CLAHomeTopicViewController ()

@property(nonatomic, strong) CLATopicDataSource *dataSource;

@property(weak, nonatomic) IBOutlet UITableView *topicTableView;
@property(weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation CLAHomeTopicViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self subscribNotifications];
}

- (void)viewDidLoad {
    [self initDataSource];
    [self updateTeam:nil];
    [self setupPullToRefresh];
}

- (void)dealloc {
    [self unsubscribNotifications];
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

- (void)setupPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.topicTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.backgroundColor = [Constants highlightColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
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
    CLATeam *team = [[CLASignalRMessageClient sharedInstance].dataRepository getCurrentOrDefaultTeam];
    
    if (team != nil) {
        NSMutableArray *roomArray = [CLAUtility getArrayFromRLMArray:team.rooms];
        NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [roomArray sortUsingDescriptors:@[ sortDescriptor ]];
        [self updateRooms:roomArray];
    }
    
    [self.topicTableView reloadData];
    self.welcomeLabel.text =
    [NSString stringWithFormat: NSLocalizedString(@"Welcome to team %@", nil), [UserDataManager getTeam].name];
    [self didFinishRefresh];
    [self hideHud];
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
    [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
    // team loading finished will be notified through kEventTeamUpdated
    // notification which calls self.updateTeam method
}

- (void)didFinishRefresh {
    [self.topicTableView reloadData];
    [self.refreshControl endRefreshing];
    //[self.topicTableView.pullToRefreshView stopAnimating];
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
    
    [(SlidingViewController *)self.slidingViewController setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (void)showHud {
    //TODO: investigation why notification won't show, if the text here (only in this controller) ends with "...",
    [CLANotificationManager showText:NSLocalizedString(@"Loading", nil)
                   forViewController:self.parentViewController
                            withType:CLANotificationTypeMessage
                         autoDismiss:NO
                          atPosition:0];
}

- (void)hideHud {
    [CLANotificationManager dismiss];
}

@end
