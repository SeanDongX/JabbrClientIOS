//
//  RightMenuViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "RightMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "DocumentViewController.h"
#import "DocumentThread+Category.h"
#import "Constants.h"
#import "SlidingViewController.h"
#import "CLATaskWebViewController.h"
#import "ChatViewController.h"

static NSString *const kDoc = @"doc";

@interface RightMenuViewController ()
@property(nonatomic, strong) NSArray *documentThreads;
@property(nonatomic, strong) NSMutableDictionary *controllers;
@end

@implementation RightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controllers =
    [NSMutableDictionary dictionaryWithCapacity:self.documentThreads.count];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants highlightColor];
    cell.selectedBackgroundView = backgroundView;
    
    switch (indexPath.item) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Tasks", nil);
            cell.imageView.image = [Constants taskIconImage];
            break;
            
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Topic Settings", nil);
            cell.imageView.image = [Constants infoIconImage];
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UINavigationController *navController =
    [((SlidingViewController *)self.slidingViewController)
     setTopNavigationControllerWithKeyIdentifier:
     kChatNavigationController];
    
    ChatViewController *chatViewController = (ChatViewController *)[navController.viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
        
        if (indexPath.item == 0) {
            [chatViewController showTaskView];
        }
        else {
            [chatViewController showInfoView];
        }
        
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

@end
