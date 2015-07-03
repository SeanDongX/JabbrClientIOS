//
//  CLAHomeNotificationViiewController.m
//  Collara
//
//  Created by Sean on 03/07/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeNotificationViiewController.h"

//Util
#import "Constants.h"
#import "CLAWebApiClient.h"
#import "AuthManager.h"
#import "MBProgressHUD.h"
#import "CLANotificationManager.h"
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

//Custom Controls
#import "BOZPongRefreshControl.h"

@interface CLAHomeNotificationViiewController ()

@property (nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;
@property (nonatomic) BOOL isRefreshing;

@end

@implementation CLAHomeNotificationViiewController

- (void)viewDidLoad {
    [self addTalbeView];
}

- (void)addTalbeView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidLayoutSubviews
{
    //The very first time this is called, the table view has a smaller size than the screen size
    if (self.tableView.frame.size.width >= [UIScreen mainScreen].bounds.size.width) {
        self.pongRefreshControl = [BOZPongRefreshControl attachToTableView:self.tableView
                                                         withRefreshTarget:self
                                                          andRefreshAction:@selector(refreshTriggered)];
        self.pongRefreshControl.backgroundColor = [Constants highlightColor];
    }
}

- (void)updateTeam:(NSNotification *)notification {
    CLATeamViewModel *teamViewModel = [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam];
    
    if (teamViewModel != nil) {
        [self updatetNotifications:teamViewModel.users];
    }
    
    [self didFinishRefresh];
}

- (void)updatetNotifications: (NSArray *)users {
    if (users != nil) {
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark - Pull To Resfresh

- (void)refreshTriggered
{
    [CLAUtility setUserDefault:[NSDate date] forKey:kLastRefreshTime];
    self.isRefreshing = TRUE;
    [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
    //team loading finished will be notified through kEventTeamUpdated notification which calls self.updateTeam method
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pongRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pongRefreshControl scrollViewDidEndDragging];
}

- (void)didFinishRefresh {
    
    if (!self.isRefreshing) {
        return;
    }
    
    NSDate *lastRefreshTime = [CLAUtility getUserDefault:kLastRefreshTime];
    NSTimeInterval remainTime = 0;
    
    if (![lastRefreshTime isEqual:[NSNull null]]) {
        remainTime =  minRefreshLoadTime + [lastRefreshTime timeIntervalSinceNow];
        remainTime = remainTime > minRefreshLoadTime ? minRefreshLoadTime : remainTime;
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

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return NSLocalizedString(@"Notifs", nil);
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    
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

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -
#pragma mark Private Methods


- (void)showCreateTopicView {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    createRoomViewController.slidingMenuViewController = (SlidingViewController *)self.slidingViewController;
    [self presentViewController:createRoomViewController animated:YES completion:nil];
}

@end
