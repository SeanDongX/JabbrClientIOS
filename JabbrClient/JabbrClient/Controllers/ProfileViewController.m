//
//  ProfileViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "ProfileViewController.h"

//Util
#import "Constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "AuthManager.h"
#import <JSQMessagesViewController/JSQMessages.h>

//Service
#import "CLASignalRMessageClient.h"
#import "CLAAzureHubPushNotificationService.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"

//ViewControllers
#import "SlidingViewController.h"
#import "ProfileViewController.h"

@interface ProfileViewController()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuItem;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self.signOutButton layer] setCornerRadius:5.0f];
    [[self.signOutButton layer] setMasksToBounds:YES];
    [[self.signOutButton layer] setBorderWidth:1.0f];
    [[self.signOutButton layer] setBorderColor: [Constants mainThemeColor].CGColor];
    
    [self.signOutButton setTitleColor:[Constants mainThemeColor] forState:UIControlStateNormal];
    
    [self.menuItem setTitle:@""];
    [self.menuItem setWidth:30];
    [self.menuItem setImage: [Constants menuIconImage]];
    
    [self.nameLabel setText:[self getUserRealName]];
    
    FAKIonIcons *userIcon = [FAKIonIcons iosPersonIconWithSize:50];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    NSString *initial = [self getUserRealName].length > 1 ? [[self getUserRealName] substringToIndex:1] : @"";
    
    [self.profileImageView setImage:[JSQMessagesAvatarImageFactory avatarImageWithUserInitials:[initial uppercaseString]
                                               backgroundColor: [Constants mainThemeContrastColor]
                                                     textColor: [UIColor whiteColor]
                                                          font:[UIFont systemFontOfSize:18]
                                                      diameter:50.0f].avatarImage];
}


- (IBAction)leftMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}
- (IBAction)signOutClicked:(id)sender {
    [[AuthManager sharedInstance] signOut];
    [[CLAAzureHubPushNotificationService sharedInstance] unregisterDevice];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [[CLASignalRMessageClient sharedInstance].dataRepository deleteData];
    //TODO:MessageClient clear data repository
    [self switchToSignInView];
}

#pragma mark -
#pragma mark Private Methods

- (void)switchToSignInView {
    
    SlidingViewController *slidingViewController = (SlidingViewController *)self.navigationController.slidingViewController;

    [slidingViewController clearControllerCache];
    [slidingViewController switchToSignInView];
}

- (NSString *)getUserRealName {
    NSString *username = [[AuthManager sharedInstance] getUsername];
    
    if (username != nil) {
        CLAUser *user = [[[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam] findUser:username];
        if (user != nil && user.realName != (id)[NSNull null] && user.realName.length != 0 ) {
            username = user.realName;
        }
    }
    else {
        username = @"";
    }
    
    return username;
}


@end
