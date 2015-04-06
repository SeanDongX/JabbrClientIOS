// LeftMenuViewController.m
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
#import "DemoData.h"
#import "ChatThread+Category.h"
#import "Constants.h"

static NSString * const kChat = @"chat";
static NSString * const kSettings = @"settings";


@interface LeftMenuViewController ()
@property (nonatomic, strong) NSArray *chatThreads;
@property (nonatomic, strong) NSMutableDictionary *controllers;
@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controllers = [NSMutableDictionary dictionaryWithCapacity:self.chatThreads.count];
    
    UINavigationController *topNavigaionController = (UINavigationController *)self.slidingViewController.topViewController;
    
    if ([topNavigaionController.visibleViewController isKindOfClass:[ChatViewController class]])
    {
        [self.controllers setObject:topNavigaionController forKey:kChat];
        [topNavigaionController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    
    self.slidingViewController.anchorLeftPeekAmount  = 50.0;
    self.slidingViewController.anchorRightPeekAmount = 50.0;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Properties

- (NSArray *)chatThreads {
    return [DemoData sharedDemoData].chatThreads;
}


- (void)resetTopViewController {
    UINavigationController *navController = [self.controllers objectForKey:kChat];
    
    if (navController != nil)
    {
        [self.controllers removeObjectForKey:kChat];
    }
    
    [self.controllers setObject:self.slidingViewController.topViewController forKey:kChat];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Last one for settings
    return self.chatThreads.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row >= self.chatThreads.count) {
        cell.textLabel.text = @"Settings";
    }
    else {
        ChatThread *chatThread = self.chatThreads[indexPath.row];
        cell.textLabel.text = [chatThread getDisplayTitle];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)setNavController:(ChatThread *)chatThread {
    UINavigationController *navController = [self.controllers objectForKey:kChat];
    
    if (navController == nil)
    {
        NSLog(@"No chat navigation view controller found in its controllers array");
        return;
    }
    
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.controllers setObject:navController forKey:kChat];
    
    
    self.slidingViewController.topViewController = navController;
    
    ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        [chatViewController switchToChatThread:chatThread];
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);

    if (indexPath.row > self.chatThreads.count) {
        
        NSString *viewControllerIdentifier = @"METransitionsNavigationController";
        
        UINavigationController *navController = [self.controllers objectForKey:kSettings];
        
        if (!navController){
            navController = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
            [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
            [self.controllers setObject:navController forKey:kSettings];
        }
        
        self.slidingViewController.topViewController = navController;
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    else {
        [self setNavController:self.chatThreads[indexPath.row]];
    }
}

@end
