//
//  SignInViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "SignInViewController.h"

// Utils
#import "Constants.h"
#import "UserDataManager.h"
#import "CLANotificationManager.h"

// Services
#import "CLAWebApiClient.h"
#import "CLAAzureHubPushNotificationService.h"

// Contorls
#import "CLARoundFrameButton.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"
#import "CLASignUpViewController.h"
#import "CLATeam.h"

@interface SignInViewController ()

@property(weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic) IBOutlet CLARoundFrameButton *signInButton;
@property(weak, nonatomic) IBOutlet CLARoundFrameButton *signUpButton;
@property(weak, nonatomic) IBOutlet CLARoundFrameButton *forgotPasswordButton;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupControls {
    [self.signInButton setButtonStyle:[UIColor whiteColor]];
    [self.signUpButton setButtonStyle:[UIColor whiteColor]];
    [self.forgotPasswordButton setButtonStyle:[UIColor whiteColor]];
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

#pragma mark -
#pragma mark - Event Handler
- (IBAction)signInClicked:(id)sender {
    
    NSString *username = [self.usernameTextField text];
    NSString *password = [self.passwordTextField text];
    
    // Trim leading and trailing space in user name; since signAPI does not
    // anyways when sign in
    
    username = [username
                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (username == nil || username.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"Oops, an empty username won't get very far.",
                                    nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return;
    }
    
    if (password == nil || password.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"Oops, an empty password won't get very far.",
                                    nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return;
    }
    
    [CLANotificationManager showText:NSLocalizedString(@"Signing in...", nil)
                   forViewController:self
                            withType:CLANotificationTypeMessage];
    
    __weak __typeof(&*self) weakSelf = self;
    
    [[CLAWebApiClient sharedInstance]
     signInWith:username
     password:password
     completionHandler:^(NSString *errorMessage) {
         __strong __typeof(&*weakSelf) strongSelf = weakSelf;
         
         [CLANotificationManager dismiss];
         [strongSelf processSignInResult:errorMessage];
     }];
}

- (IBAction)signUpClicked:(id)sender {
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kMainStoryBoard bundle:nil];
    
    CLASignUpViewController *signUpViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kSignUpController];
    signUpViewController.slidingViewController =
    (SlidingViewController *)self.navigationController.slidingViewController;
    [self presentViewController:signUpViewController animated:YES completion:nil];
}

- (IBAction)forgotPasswordClicked:(id)sender {
    [[UIApplication sharedApplication]
     openURL:[[NSURL alloc]
              initWithString:[NSString
                              stringWithFormat:@"%@%@", kServerBaseUrl,
                              kForgotPasswordPath]]];
}

- (void)processSignInResult:(NSString *)errorMessage {
    if (errorMessage == nil) {
        [[CLAAzureHubPushNotificationService sharedInstance] registerDevice];
        [self switchToMainView];
        [self cleanUpForm];
    } else {
        [CLANotificationManager showText:errorMessage
                       forViewController:self
                                withType:CLANotificationTypeError];
    }
}

- (void)switchToMainView {
    [[CLAWebApiClient sharedInstance]
     getTeams:^(NSArray<CLATeam *> *teams, NSString *errorMessage) {
         if (teams != nil && teams.count > 0) {
             [((SlidingViewController *)self.navigationController.slidingViewController)
              switchToMainView];
         }
         else {
             [((SlidingViewController *)self.navigationController.slidingViewController) switchToCreateTeamView:nil
                                                                                           sourceViewIdentifier:nil];
         }
     }];
}

#pragma mark -
#pragma mark Private Methods

- (void)cleanUpForm {
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
}
@end
