//
//  RightMenuViewController.hViewController
//  JabbrClient
//
//  Created by Sean on 31/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "RightMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ChatViewController.h"

@interface RightMenuViewController ()
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllers;
@property (nonatomic, strong) UINavigationController *navigationController;
@end

@implementation RightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controllers = [NSMutableDictionary dictionaryWithCapacity:self.menuItems.count];
    
    // topViewController is the transitions navigation controller at this point.
    // It is initially set as a User Defined Runtime Attributes in storyboards.
    // We keep a reference to this instance so that we can go back to it without losing its state.
    self.navigationController = (UINavigationController *)self.slidingViewController.topViewController;
    [self.controllers setObject:self.navigationController forKey:@"PitchSpeech"];
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 200, 0, 0);
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Properties

- (NSArray *)menuItems {
    if (_menuItems) return _menuItems;
    
    _menuItems = @[@"PitchSpeech", @"FeatureDocument"];
    
    return _menuItems;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *menuItem = self.menuItems[indexPath.row];
    
    if (indexPath.row == 3) {
        cell.textLabel.text = menuItem;
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", menuItem];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)setNavController:(NSString *)menuItem {
    NSString *key = @"Docs";
    NSString *viewControllerIdentifier = @"DocumentNavigationController";
    
    UINavigationController *navController = [self.controllers objectForKey:key];
    
    if (!navController){
        navController = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
        [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
        [self.controllers setObject:navController forKey:key];
    }
    
    self.slidingViewController.topViewController = navController;

    ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
    
    ChatThread *chatThread = [[ChatThread alloc] init];
    chatThread.name = menuItem;
    [chatViewController switchToChatThread:chatThread];
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
    NSString *menuItem = self.menuItems[indexPath.row];
    [self setNavController:menuItem];
}

@end
