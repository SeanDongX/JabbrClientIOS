//
//  CLACreateRoomViewController.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLACreateRoomViewController.h"
#import "Constants.h"
#import "SlidingViewController.h"
#import "CLAToastManager.H"

@interface CLACreateRoomViewController ()

@property (weak, nonatomic) IBOutlet UITextField *topicLabel;
@end

@implementation CLACreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kStatusBarHeight)];
    navBar.barTintColor = [Constants mainThemeColor];
    navBar.translucent = NO;
    navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Create Topic";
    [navBar setItems:@[navItem]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.rightBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}


- (void)closeButtonClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)goButtonClicked:(id)sender {
    
    NSString *topic = self.topicLabel.text;
    
    [self.messageClient createTeam:topic completionBlock:^(NSError *error){
        if (error == nil) {
            //TODO: create existing topic should also go to the topic
            [self.slidingMenuViewController switchToRoom:topic];
        }
        else {
            //TODO: define error code
            [CLAToastManager showDefaultInfoToastWithText: @"Oh, something went wrong. Let's try it again." completionBlock:nil];
        }
    }];
}


@end
