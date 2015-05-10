//
//  CLASignUpViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignUpViewController.h"
#import "CLAWebApiClient.h"
#import "CRToast.h"
#import "CLAUtility.h"

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

#pragma mark - 
#pragma mark Event Handlers

- (IBAction)signUpClicked:(id)sender {
    
    CLAUserRegistrationViewModel *accountModel = [[CLAUserRegistrationViewModel alloc] init];
    accountModel.username = [self usernameTextField].text;
    accountModel.email = [self emailTextField].text;
    accountModel.password = [self passwordTextField].text;
    accountModel.confirmPassword = [self repeatPasswordTextField].text;
    
    if ([self isValidAccountModel:accountModel]) {
        [[CLAWebApiClient sharedInstance] createAccount:accountModel completionHandler:^(NSString *errorMessage) {
            if (errorMessage == nil) {
                [self.slidingViewController switchToMainView];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [CRToastManager showNotificationWithMessage:errorMessage completionBlock:nil];
            }
        }];
    }
}

- (IBAction)signInClicked:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (BOOL)isValidAccountModel: (CLAUserRegistrationViewModel *)accountModel {

    if (accountModel.username.length == 0) {
        [CRToastManager showNotificationWithMessage:@"Uesrname is empty" completionBlock:nil];
        return NO;
    }
    
    if (accountModel.email.length == 0) {
        [CRToastManager showNotificationWithMessage:@"Email is empty" completionBlock:nil];
        return NO;
    }
    
    if (![CLAUtility isValidEmail:accountModel.email]) {
        [CRToastManager showNotificationWithMessage:@"Email is invalid" completionBlock:nil];
        return NO;
    }
    if (accountModel.password.length == 0) {
        [CRToastManager showNotificationWithMessage:@"Password is empty" completionBlock:nil];
        return NO;
    }
    
    if (![accountModel.password isEqual:accountModel.confirmPassword]) {
        [CRToastManager showNotificationWithMessage:@"Password does not match" completionBlock:nil];
        return NO;
    }
    
    return YES;
}

@end
