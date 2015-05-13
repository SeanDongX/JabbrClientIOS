//
//  CLAHomeViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeViewController.h"

//Util
#import "Constants.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

//View Controller
#import "CLACreateRoomViewController.h"
#import "ChatViewController.h"

@interface CLAHomeViewController ()
@property (weak, nonatomic) IBOutlet UITableView *topicTableView;
@property (weak, nonatomic) IBOutlet UITableView *teamMemberTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuItem;

@end

@implementation CLAHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI {
    [self.menuItem setTitle:@""];
    [self.menuItem setWidth:30];    
    [self.menuItem setImage: [Constants menuIconImage]];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.topicTableView) {
        switch (section) {
            case 0:
                return 0;//TODO:add count from ds
                
            default:
                return 0;
        }
    }
    else {
        switch (section) {
            case 0:
                return 0;//TODO:add count from ds
                
            default:
                return 0;
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.topicTableView){
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
    
//    ChatThread *chatThread = self.chatThreads[indexPath.row];
//    cell.textLabel.text = [chatThread getDisplayTitle];
//    
//    cell.textLabel.textColor = [UIColor whiteColor];
//    [cell setBackgroundColor:[UIColor clearColor]];
//    
//    UIView *backgroundView = [UIView new];
//    backgroundView.backgroundColor = [Constants mainThemeColor];
//    cell.selectedBackgroundView = backgroundView;
//    
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamMemeberCell"];
        return cell;
    }
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
    
    UIView *hightlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 5, 30)];
    [hightlightView setBackgroundColor:[Constants mainThemeColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    title.textColor = [UIColor whiteColor];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor: [Constants mainThemeContrastFocusColor]];
    
    [headerView addSubview:hightlightView];
    [headerView addSubview:title];
    
    if (tableView == self.topicTableView) {
        title.text = [NSString stringWithFormat: NSLocalizedString(@"Topics (%lu)", nil), 0];
        
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 10, 30, 30)];
        [addButton addTarget:self action:@selector(showCreateTopicView) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
        [headerView addSubview:addButton];
    }
    else {
        title.text = [NSString stringWithFormat: NSLocalizedString(@"Team members (%lu)", nil), 0];

    }
    
    return headerView;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navController = nil;
    
    navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        //[chatViewController switchToChatThread:self.chatThreads[indexPath.row]];
    }
    
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

#pragma mark -
#pragma mark - Event Handlers

- (IBAction)leftMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)showCreateTopicView {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    createRoomViewController.slidingMenuViewController = (SlidingViewController *)self.slidingViewController;
    [self presentViewController:createRoomViewController animated:YES completion:nil];
}
@end
