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
#import <FontAwesomeKit/FAKIonIcons.h>

@interface ProfileViewController()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuItem;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    
    [[self.signOutButton layer] setCornerRadius:5.0f];
    [[self.signOutButton layer] setMasksToBounds:YES];
    [[self.signOutButton layer] setBorderWidth:1.0f];
    [[self.signOutButton layer] setBorderColor: [Constants mainThemeColor].CGColor];
    
    [self.signOutButton setTitleColor:[Constants mainThemeColor] forState:UIControlStateNormal];
    
    [self.menuItem setTitle:@""];
    [self.menuItem setWidth:30];
    
    [self.menuItem setImage: [Constants menuIconImage]];
    [self.nameLabel setText:[[AuthManager sharedInstance] getUsername]];
    
    FAKIonIcons *userIcon = [FAKIonIcons iosPersonIconWithSize:50];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];

    [self.profileImageView setImage: [userIcon imageWithSize:CGSizeMake(50, 50)]];
    self.profileImageView.layer.cornerRadius = 50;
    self.profileImageView.layer.borderWidth = 2;
    self.profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.profileImageView.layer.backgroundColor = [Constants mainThemeColor].CGColor;
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
