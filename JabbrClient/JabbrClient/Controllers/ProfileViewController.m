//
//  ProfileViewController.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "AuthManager.h"
#import "Constants.h"
#import "SlidingViewController.h"

@interface ProfileViewController()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameLabel setText:[[AuthManager sharedInstance] getUsername]];
    
    //TODO: set profile image
    
}

- (IBAction)leftMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}
- (IBAction)signOutClicked:(id)sender {
    [[AuthManager sharedInstance] signOut];
    [self switchToSignInView];
}

- (void)switchToSignInView {
    [((SlidingViewController *)self.navigationController.slidingViewController) switchToSignInView];
}

@end
