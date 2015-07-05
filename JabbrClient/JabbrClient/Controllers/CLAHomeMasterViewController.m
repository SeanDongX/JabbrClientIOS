//
//  CLAHomeMasterViewController.m
//  Collara
//
//  Created by Sean on 31/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAHomeMasterViewController.h"

//Util
#import "Constants.h"
#import "MBProgressHUD.h"
#import "CLASignalRMessageClient.h"
//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

//View Controller
#import "CLAHomeTopicViewController.h"
#import "CLAHomeMemberViewController.h"
#import "CLAHomeNotificationViiewController.h"

@interface CLAHomeMasterViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CLAHomeMasterViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.skipIntermediateViewControllers = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self subscribNotifications];
    [self initUI];
}

- (void)dealloc {
    [self unsubscribNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0);
    if (![CLASignalRMessageClient sharedInstance].teamLoaded) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //scroll view's scroll behavior is disabled.
    //The code below disables scroll view y contnet offset, otherwise the page will have a top offset.
    //If page scroll need to be enabled, need to do this in XLPagerTabStripViewController viewDidScroll method
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0);
}

#pragma mark -
#pragma mark Notifications
- (void)subscribNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTeam) name:kEventTeamUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCreateTeamView) name:kEventNoTeam object:nil];
}

- (void)unsubscribNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initUI {
    [self.menuItem setTitle:@""];
    [self.menuItem setWidth:30];
    [self.menuItem setImage: [Constants menuIconImage]];
}

#pragma mark -
#pragma mark - Event Handlers

- (IBAction)leftMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


#pragma mark -
#pragma mark View Controller Event Handlers

- (void)updateTeam {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)showCreateTeamView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    SlidingViewController *slidingViewController = (SlidingViewController *)self.slidingViewController;
    [slidingViewController switchToCreateTeamView];
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLAHomeTopicViewController *homeTopicViewController = [storyBoard instantiateViewControllerWithIdentifier:kHomeTopicViewController];
    
    CLAHomeMemberViewController *homeMemberViewController = [storyBoard instantiateViewControllerWithIdentifier:kHomeMemberViewController];
    
    
    //CLAHomeNotificationViiewController *notificationViewController = [[CLAHomeNotificationViiewController alloc] init];
    
    return @[homeTopicViewController, homeMemberViewController];//, notificationViewController];
}

@end
