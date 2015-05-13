//
//  CLASignUpViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignUpViewController.h"

//Util
#import "Constants.h"
#import "CLAToastManager.h"
#import "CLAUtility.h"

//API Client
#import "CLAWebApiClient.h"

@interface CLASignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation CLASignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 
#pragma mark Event Handlers

- (IBAction)signUpClicked:(id)sender {
    
    CLAUserRegistrationViewModel *accountModel = [[CLAUserRegistrationViewModel alloc] init];
    accountModel.username = [self usernameTextField].text;
    accountModel.email = [self emailTextField].text;
    accountModel.password = [self passwordTextField].text;
    accountModel.confirmPassword = [self repeatPasswordTextField].text;
    
    __weak __typeof(&*self)weakSelf = self;
    
    if ([self isValidAccountModel:accountModel]) {
        [[CLAWebApiClient sharedInstance] createAccount:accountModel completionHandler:^(NSString *errorMessage) {
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            
            if (errorMessage == nil) {
                [strongSelf.slidingViewController switchToMainView];
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [CLAToastManager showDefaultInfoToastWithText: errorMessage completionBlock:nil];
            }
        }];
    }
}

- (IBAction)signInClicked:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (BOOL)isValidAccountModel: (CLAUserRegistrationViewModel *)accountModel {

    if (accountModel.username.length == 0) {
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"Oops, an empty username won't get very far.", nil) completionBlock:nil];
        return NO;
    }

    if (accountModel.email.length == 0) {
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"We will need your email.", nil) completionBlock:nil];
        return NO;
    }
    
    if (![CLAUtility isValidEmail:accountModel.email]) {
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"We will need a valid email address.", nil) completionBlock:nil];
        return NO;
    }
    if (accountModel.password.length < 6) {
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"How about a password with more than 6 characters?", nil) completionBlock:nil];
        return NO;
    }
    
    if (![accountModel.password isEqual:accountModel.confirmPassword]) {
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"Oops, the passwords does not match.", nil) completionBlock:nil];
        return NO;
    }
    
    return YES;
}

@end
