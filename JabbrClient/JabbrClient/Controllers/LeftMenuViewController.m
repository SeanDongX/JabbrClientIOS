// MEMenuViewController.m
// TransitionFun
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LeftMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ChatViewController.h"

@interface LeftMenuViewController ()
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllers;
@property (nonatomic, strong) UINavigationController *navigationController;
@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controllers = [NSMutableDictionary dictionaryWithCapacity:self.menuItems.count];
    
    // topViewController is the transitions navigation controller at this point.
    // It is initially set as a User Defined Runtime Attributes in storyboards.
    // We keep a reference to this instance so that we can go back to it without losing its state.
    self.navigationController = (UINavigationController *)self.slidingViewController.topViewController;
    [self.controllers setObject:self.navigationController forKey:@"PitchDemo"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Properties

- (NSArray *)menuItems {
    if (_menuItems) return _menuItems;
    
    _menuItems = @[@"PitchDemo", @"FeaturePlanning", @"collabot", @"Settings"];
    
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
        cell.textLabel.text = [NSString stringWithFormat:@"#%@", menuItem];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)setNavController:(NSString *)menuItem {
    NSString *key = @"Chat";
    NSString *viewControllerIdentifier = @"ChatNavigationController";
    BOOL setThread = TRUE;
    
    if ([menuItem isEqualToString:@"Settings"]) {
        key = @"Settings";
        viewControllerIdentifier = @"METransitionsNavigationController";
        setThread = FALSE;
    }
    
    UINavigationController *navController = [self.controllers objectForKey:key];
    
    if (!navController){
        navController = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
        [self.controllers setObject:navController forKey:key];
    }
    
    self.slidingViewController.topViewController = navController;
    
    if (setThread){
        ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
        
        ChatThread *chatThread = [[ChatThread alloc] init];
        chatThread.name = menuItem;
        [chatViewController switchToChatThread:chatThread];
    }
    
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
