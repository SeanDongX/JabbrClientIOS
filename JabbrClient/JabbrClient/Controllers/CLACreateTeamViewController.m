//
//  CLACreateTeamViewController.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLACreateTeamViewController.h"

//Util
#import "Constants.h"
#import "CLAToastManager.h"
#import "AuthManager.h"

//API Client
#import "CLAWebApiClient.h"

@interface CLACreateTeamViewController ()

@property (weak, nonatomic) IBOutlet UITextField *teamNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;

@end

@implementation CLACreateTeamViewController

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
    navItem.title = @"Pick Your Team";
    [navBar setItems:@[navItem]];
    
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc] initWithImage: [Constants signOutImage]
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(signOut)];
    signOutButton.tintColor = [UIColor whiteColor];
    navItem.rightBarButtonItem = signOutButton;
    
    [self.view addSubview:navBar];
}

#pragma mark -
#pragma mark Event Handlers

- (IBAction)createTeamClicked:(id)sender {
    NSString *teamName = self.teamNameTextField.text;
    
    if ( teamName == nil || teamName.length == 0) {
        
        [CLAToastManager showDefaultInfoToastWithText:@"Oh, an empty name. That will not work." completionBlock:nil];
    }
    else if (teamName.length > kTeamNameMaxLength) {
        
        [CLAToastManager showDefaultInfoToastWithText:[NSString stringWithFormat:@"Awww, do you really need more than %d characters for your team name?", kTeamNameMaxLength ]completionBlock:nil];
    }
    else {
        
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        [apiClient createTeam:teamName completionHandler: ^(NSString *errorMessage){
        
            if (errorMessage == nil) {
                [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
                [self dismissViewControllerAnimated:YES completion: nil];
            }
            else {
                
                [CLAToastManager showDefaultInfoToastWithText:errorMessage completionBlock:nil];
            }
        
        }];
    }
    
}

- (IBAction)joinTeamButtonClicked:(id)sender {
    NSString *inviteCode = self.inviteCodeTextField.text;
    
    if ( inviteCode == nil || inviteCode.length == 0) {
        
        [CLAToastManager showDefaultInfoToastWithText:@"Oh, an empty invitation code. That will not work." completionBlock:nil];
    }
    else {
        
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        [apiClient joinTeam:inviteCode completionHandler: ^(NSString *errorMessage){
            
            if (errorMessage == nil) {
                [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
                [self dismissViewControllerAnimated:YES completion: nil];
            }
            else {
                
                [CLAToastManager showDefaultInfoToastWithText:errorMessage completionBlock:nil];
            }
            
        }];
    }
}

#pragma mark -
#pragma mark Private Methods

- (void)signOut {
    [[AuthManager sharedInstance] signOut];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [self switchToSignInView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchToSignInView {
    [self.slidingMenuViewController switchToSignInView];
}

@end
