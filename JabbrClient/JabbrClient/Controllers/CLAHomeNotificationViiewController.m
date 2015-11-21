//
//  CLAHomeNotificationViiewController.m
//  Collara
//
//  Created by Sean on 03/07/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeNotificationViiewController.h"

// Util
#import <MagicalRecord/MagicalRecord.h>
#import "Constants.h"
#import "CLAWebApiClient.h"
#import "AuthManager.h"
#import "MBProgressHUD.h"
#import "CLANotificationManager.h"
#import "CLASignalRMessageClient.h"
#import "CLAUtility.h"

// Data Model
#import "CLAUser.h"
#import "CLATeamViewModel.h"
#import "CLANotificationMessage.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

// View Controllers
#import "CLACreateRoomViewController.h"
#import "CLANotificationContentViewController.h"

// Custom Controls
#import "BOZPongRefreshControl.h"
#import "CLANotifictionTableViewCell.h"

@interface CLAHomeNotificationViiewController ()

@property(nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;
@property(nonatomic) BOOL isRefreshing;

@end

@implementation CLAHomeNotificationViiewController

- (void)viewDidLoad {
    [self addTalbeView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadNotifications];
}

- (void)addTalbeView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)loadNotifications {
    [[CLAWebApiClient sharedInstance]
     getNotificationsFor:[CLAUtility getUserDefault:kTeamKey]
     completion:^(NSArray *result, NSString *errorMessage) {
         
         [MagicalRecord
          saveWithBlock:^(NSManagedObjectContext *localContext) {
              for (NSDictionary *dataDictionary in result) {
                  NSNumber *notificationKey =
                  [dataDictionary objectForKey:@"notificationKey"];
                  
                  CLANotificationMessage *existingNotification =
                  [CLANotificationMessage
                   MR_findFirstByAttribute:@"notificationKey"
                   withValue:notificationKey
                   inContext:localContext];
                  
                  if (existingNotification != nil) {
                      [existingNotification updateExisting:dataDictionary];
                  } else {
                      CLANotificationMessage *notification =
                      [CLANotificationMessage
                       MR_createEntityInContext:localContext];
                      [notification parseData:dataDictionary];
                  }
              }
              
          }
          completion:^(BOOL success, NSError *error) {
              [self.tableView reloadData];
              [self finishRefresh];
              [MBProgressHUD hideHUDForView:self.view animated:YES];
          }];
         
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
     }];
}

- (void)viewDidLayoutSubviews {
    // The very first time this is called, the table view has a smaller size than
    // the screen size
    if (self.tableView.frame.size.width >=
        [UIScreen mainScreen].bounds.size.width) {
        self.pongRefreshControl =
        [BOZPongRefreshControl attachToTableView:self.tableView
                               withRefreshTarget:self
                                andRefreshAction:@selector(refreshTriggered)];
        self.pongRefreshControl.backgroundColor = [Constants highlightColor];
    }
}

#pragma mark -
#pragma mark - Pull To Resfresh

- (void)refreshTriggered {
    [CLAUtility setUserDefault:[NSDate date] forKey:kLastRefreshTime];
    self.isRefreshing = TRUE;
    [self loadNotifications];
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
}

#pragma mark - XLPagerTabStripViewControllerDelegate

- (NSString *)titleForPagerTabStripViewController:
(XLPagerTabStripViewController *)pagerTabStripViewController {
    return NSLocalizedString(@"Alerts", nil);
}

- (UIColor *)colorForPagerTabStripViewController:
(XLPagerTabStripViewController *)pagerTabStripViewController {
    return [UIColor whiteColor];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [CLANotificationMessage MR_findAll].count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"NotificationCell";
    
    CLANotifictionTableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CLANotifictionTableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:cellIdentifier];
    }
    
    cell.notification =
    [[CLANotificationMessage MR_findAllSortedBy:@"when" ascending:NO]
     objectAtIndex:indexPath.row];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants highlightColor];
    cell.selectedBackgroundView = backgroundView;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

#pragma mark - Table Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showNotificationContent:
     [[CLANotificationMessage MR_findAllSortedBy:@"when" ascending:NO]
      objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark Private Methods

- (void)showNotificationContent:(CLANotificationMessage *)notification {
    if (notification == nil) {
        return;
    }
    
    [[CLAWebApiClient sharedInstance]
     setRead:notification
     completion:^(NSArray *result, NSString *errorMessage) {
         [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
             CLANotificationMessage *existingNotification = [CLANotificationMessage
                                                             MR_findFirstByAttribute:@"notificationKey"
                                                             withValue:notification.notificationKey
                                                             inContext:localContext];
             existingNotification.read = @1;
         } completion:^(BOOL success, NSError *error){
         }];
     }];
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kMainStoryBoard bundle:nil];
    
    CLANotificationContentViewController *notificationViewController =
    [storyBoard instantiateViewControllerWithIdentifier:
     kNotificationContentViewController];
    notificationViewController.notification = notification;
    [self presentViewController:notificationViewController
                       animated:YES
                     completion:nil];
}

@end
