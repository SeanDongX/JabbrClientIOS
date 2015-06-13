//
//  SignInViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "SignInViewController.h"

//Utils
#import "Constants.h"
#import "AuthManager.h"
#import "CLAToastManager.h"
#import "MBProgressHUD.h"

//Services
#import "CLAWebApiClient.h"
#import "CLAAzureHubPushNotificationService.h"

//Contorls
#import "CLARoundFrameButton.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"
#import "CLASignUpViewController.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet CLARoundFrameButton *signInButton;
@property (weak, nonatomic) IBOutlet CLARoundFrameButton *signUpButton;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
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

- (void)setupButtons {
    [self.signInButton setButtonStyle:[UIColor whiteColor]];
    [self.signUpButton setButtonStyle:[UIColor whiteColor]];
}

#pragma mark -
#pragma mark - Event Handler
- (IBAction)signInClicked:(id)sender {
    
    NSString *username = [self.usernameTextField text];
    NSString *password = [self.passwordTextField text];
    
    //Trim leading and trailing space in user name; since signAPI does not anyways when sign in
    
    username = [username stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
    
    if (username == nil || username.length == 0) {
        
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"Oops, an empty username won't get very far.", nil)completionBlock:nil];
        return;
    }
    
    if (password == nil || password.length == 0) {
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"Oops, an empty password won't get very far.", nil) completionBlock:nil];
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    
    [[CLAWebApiClient sharedInstance] signInWith:username
                                        password:password
                                     completionHandler:^(NSString *errorMessage) {
                                     __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                                         
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      [strongSelf processSignInResult:errorMessage];
    }];
}

- (IBAction)signUpClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLASignUpViewController *signUpViewController = [storyBoard instantiateViewControllerWithIdentifier:kSignUpController];
    signUpViewController.slidingViewController = (SlidingViewController *)self.navigationController.slidingViewController;
    [self presentViewController:signUpViewController animated:YES completion:nil];
}


- (void)processSignInResult: (NSString *)errorMessage {
    if (errorMessage == nil) {
        [[CLAAzureHubPushNotificationService sharedInstance] registerDevice];
        [self cleanUpForm];
        [self switchToMainView];
    }
    else {
        [CLAToastManager showDefaultInfoToastWithText:errorMessage completionBlock:nil];
    }
}

- (void)switchToMainView {
    [((SlidingViewController *)self.navigationController.slidingViewController) switchToMainView];
}

#pragma mark -
#pragma mark Private Methods

- (void)cleanUpForm {
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
}
@end
