//
//  SlidingViewController.m
//  JabbrClient
//
//  Created by Sean on 05/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "SlidingViewController.h"
#import "AuthManager.h"
#import "SignInViewController.h"
#import "Constants.h"

@interface SlidingViewController ()

@end

@implementation SlidingViewController

- (void)awakeFromNib {
    self.underLeftViewControllerStoryboardId = kLeftMenuViewController;
    self.underRightViewControllerStoryboardId = kRightMenuViewController;
    
    if ([AuthManager sharedInstance].isAuthenticated) {
        self.topViewControllerStoryboardId = kChatNavigationController;
    }
    else {
        self.topViewControllerStoryboardId = kSignInNavigationController;
    }
    
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
