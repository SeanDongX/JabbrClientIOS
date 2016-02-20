//
//  CLASignUpViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignUpViewController.h"

// Util
#import "Constants.h"
#import "CLANotificationManager.h"
#import "CLAUtility.h"

// Control
#import "CLARoundFrameButton.h"

// API Client
#import "CLAWebApiClient.h"
#import "UserDataManager.h"

@interface CLASignUpViewController ()

@property(weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property(weak, nonatomic) IBOutlet UITextField *nameTextField;
@property(weak, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property(weak, nonatomic) IBOutlet CLARoundFrameButton *signUpButton;
@property(weak, nonatomic) IBOutlet CLARoundFrameButton *signInButton;

@end

@implementation CLASignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupControls];
}

- (void)setupControls {
    [self.signInButton setButtonStyle:[UIColor whiteColor]];
    [self.signUpButton setButtonStyle:[UIColor whiteColor]];
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

#pragma mark -
#pragma mark Event Handlers

- (IBAction)signUpClicked:(id)sender {
    [CLANotificationManager showText:NSLocalizedString(@"Trying to create account...", nil)
                   forViewController:self
                            withType:CLANotificationTypeMessage];
    
    CLAUserRegistrationViewModel *accountModel =
    [[CLAUserRegistrationViewModel alloc] init];
    accountModel.username = [self usernameTextField].text;
    accountModel.name = [self nameTextField].text;
    accountModel.email = [self emailTextField].text;
    accountModel.password = [self passwordTextField].text;
    accountModel.confirmPassword = [self repeatPasswordTextField].text;
    
    __weak __typeof(&*self) weakSelf = self;
    
    if ([self isValidAccountModel:accountModel]) {
        [[CLAWebApiClient sharedInstance]
         createAccount:accountModel
         completionHandler:^(NSString *errorMessage) {
             __strong __typeof(&*weakSelf) strongSelf = weakSelf;
             
             if (errorMessage == nil) {
                 [strongSelf switchToMainView];
                 [strongSelf cleanUpForm];
             } else {
                 [CLANotificationManager showText:errorMessage
                                forViewController:strongSelf
                                         withType:CLANotificationTypeError];
             }
             
             [CLANotificationManager dismiss];
         }];
    } else {
        [CLANotificationManager dismiss];
    }
}

- (IBAction)signInClicked:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (BOOL)isValidAccountModel:(CLAUserRegistrationViewModel *)accountModel {
    
    if (accountModel.username.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"Oops, an empty username won't get very far.",
                                    nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return NO;
    }
    
    if (accountModel.name.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"Oops, an empty name won't get very far.", nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return NO;
    }
    
    if (accountModel.email.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(@"We will need your email.", nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return NO;
    }
    
    if (![CLAUtility isValidEmail:accountModel.email]) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"We will need a valid email address.", nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return NO;
    }
    if (accountModel.password.length < 6) {
        [CLANotificationManager
         showText:
         NSLocalizedString(
                           @"How about a password with more than 6 characters?",
                           nil)
         forViewController:self
         withType:CLANotificationTypeWarning];
        return NO;
    }
    
    if (![accountModel.password isEqual:accountModel.confirmPassword]) {
        [CLANotificationManager showText:NSLocalizedString(@"Oops, the passwords do not match.", nil)
                       forViewController:self
                                withType:CLANotificationTypeWarning];
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Private Methods

- (void)cleanUpForm {
    self.usernameTextField.text = @"";
    self.nameTextField.text = @"";
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
    self.repeatPasswordTextField.text = @"";
}

- (void)switchToMainView {
    [[CLAWebApiClient sharedInstance]
     getTeams:^(NSArray<CLATeam *> *teams, NSString *errorMessage) {
         NSString *invitationId = [UserDataManager getCachedObjectForKey:kinvitationId];
         if (!invitationId && teams != nil && teams.count > 0) {
             [self dismissViewControllerAnimated: YES completion:^{
                 [((SlidingViewController *)self.slidingViewController)
                  switchToMainView];
             }];
         }
         else {
             [self dismissViewControllerAnimated: YES completion:^{
                 [((SlidingViewController *)self.slidingViewController)
                  switchToCreateTeamView:invitationId
                  sourceViewIdentifier:nil];
             }];
             [UserDataManager cacheObject:nil forKey:kinvitationId];
         }
     }];
}

@end
