//
//  CLAHomeViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeTopicViewController.h"

//Util
#import "Constants.h"

//Data Model
#import "CLARoom.h"
#import "CLARoom+Category.h"
#import "CLATeamViewModel.h"
#import "ChatThread.h"
#import "ChatThread+Category.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

//View Controller
#import "CLACreateRoomViewController.h"
#import "ChatViewController.h"
#import "CLACreateTeamViewController.h"

@interface CLAHomeTopicViewController ()

@property (weak, nonatomic) IBOutlet UITableView *topicTableView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (strong, nonatomic) NSArray<ChatThread> *rooms;
@property (strong, nonatomic) NSArray<CLAUser> *users;

@end

@implementation CLAHomeTopicViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self subscribNotifications];
}

- (void)dealloc {
    [self unsubscribNotifications];
}

#pragma mark -
#pragma mark Notifications
- (void)subscribNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTeam:) name:kEventTeamUpdated object:nil];
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTeam:(NSNotification *)notification {
    CLATeamViewModel *teamViewModel = [notification.userInfo objectForKey:kTeamKey];
    
    if (teamViewModel == nil) {
        //[self showCreateTeamView];
    }
    else {
        [self updateRooms:teamViewModel.rooms];
        
        if (teamViewModel.team != nil) {
            self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome to join team %@", nil), teamViewModel.team.name];
        }
    }
}

- (void)updateRooms: (NSArray *)rooms {
    if (rooms != nil) {
        NSMutableArray *chatThreadArray = [NSMutableArray array];
        for (CLARoom *room in rooms) {
            ChatThread *thread= [[ChatThread alloc] init];
            thread.title = room.name;
            [chatThreadArray addObject:thread];
        }
        
        self.rooms = chatThreadArray;
        [self.topicTableView reloadData];
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return NSLocalizedString(@"Topics", nil);
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicCell"];

    ChatThread *room = [self.rooms objectAtIndex:indexPath.row];
    cell.textLabel.text = [room getDisplayTitle];
    
    cell.textLabel.textColor = [Constants mainThemeContrastColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants mainThemeColor];
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
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 250, 30)];
    title.textColor = [UIColor whiteColor];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor: [Constants mainThemeContrastFocusColor]];
    
    [headerView addSubview:title];
    
    title.text = [NSString stringWithFormat: NSLocalizedString(@"Topics (%lu)", nil), [self getRoomCount]];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 10, 30, 30)];
    [addButton addTarget:self action:@selector(showCreateTopicView) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    [headerView addSubview:addButton];
    
    return headerView;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navController = nil;
    
    navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        [chatViewController switchToChatThread:[self.rooms objectAtIndex:indexPath.row]];
    }
    
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

#pragma mark -
#pragma mark Private Methods

- (NSInteger)getRoomCount {
    return self.rooms == nil ? 0 : self.rooms.count;
}
@end