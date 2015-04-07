//
//  RightMenuViewController.hViewController
//  JabbrClient
//
//  Created by Sean on 31/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "RightMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "DocumentViewController.h"
#import "DemoData.h"
#import "DocumentThread+Category.h"

static NSString * const kDoc = @"doc";

@interface RightMenuViewController ()
@property (nonatomic, strong) NSArray *documentThreads;
@property (nonatomic, strong) NSMutableDictionary *controllers;
@end

@implementation RightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controllers = [NSMutableDictionary dictionaryWithCapacity:self.documentThreads.count];
    
//    self.navigationController = (UINavigationController *)self.slidingViewController.topViewController;
//    [self.controllers setObject:self.navigationController forKey:kDoc];
//    
    //[self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];

    //self.tableView.contentInset = UIEdgeInsetsMake(0, 200, 0, 0);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Properties

- (NSArray *)documentThreads {
    return[DemoData sharedDemoData].documentThreads;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.documentThreads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    DocumentThread *documentThread = self.documentThreads[indexPath.row];
    
    cell.textLabel.text = [documentThread getDisplayTitle] ;
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)setNavController:(DocumentThread *)documentThread {
    
    NSString *viewControllerIdentifier = @"DocumentNavigationController";
    
    UINavigationController *navController = [self.controllers objectForKey:kDoc];
    
    if (!navController){
        navController = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
        [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
        [self.controllers setObject:navController forKey:kDoc];
    }
    
    self.slidingViewController.topViewController = navController;

    DocumentViewController *documentViewController = [navController.viewControllers objectAtIndex:0];
    
    [documentViewController loadDocumentThread:documentThread];
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
    DocumentThread *documenThread = self.documentThreads[indexPath.row];
    [self setNavController:documenThread];
}

@end
