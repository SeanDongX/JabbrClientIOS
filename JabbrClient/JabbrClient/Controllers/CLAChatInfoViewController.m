//
//  CLAChatInfoViewController.m
//  Collara
//
//  Created by Sean on 02/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAChatInfoViewController.h"
#import "Constants.h"

@interface CLAChatInfoViewController()

@end

@implementation CLAChatInfoViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setupNavBar];
    
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64.0)];
    navBar.barTintColor = [Constants mainThemeColor];
    navBar.translucent = NO;
    navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };

    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Topic Settings";
        [navBar setItems:@[navItem]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.rightBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}

- (void)closeButtonClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
