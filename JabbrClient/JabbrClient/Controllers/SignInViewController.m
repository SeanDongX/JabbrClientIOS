//
//  SignInViewController.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "SignInViewController.h"

//Util
#import "Constants.h"
#import "AuthManager.h"
#import "CLAWebApiClient.h"
#import "CLAToastManager.h"
#import "MBProgressHUD.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"
#import "CLASignUpViewController.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end

@implementation SignInViewController

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
#pragma mark - Event Handler
- (IBAction)signInClicked:(id)sender {
    
    NSString *username = [self.usernameTextField text];
    NSString *password = [self.passwordTextField text];
    
    if (username == nil || username.length == 0) {
        
        [CLAToastManager showDefaultInfoToastWithText:@"Did you forget your username?" completionBlock:nil];
        return;
    }
    
    if (password == nil || password.length == 0) {
        [CLAToastManager showDefaultInfoToastWithText:@"OK, that password won't work."completionBlock:nil];
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    
    [[CLAWebApiClient sharedInstance] signInWith:username
                                        password:password
                                     completionHandler:^(NSString *errorMessage) {
                                                  
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  [self processSignInResult:errorMessage];
    }];
//    [[AuthManager sharedInstance]signInWithUsername:username
//                                           password:password
//                                         completion:^(NSError *error){
//                                             
//                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                             [self processSignInResult:error];
//    }];
    
}

- (IBAction)signUpClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLASignUpViewController *signUpViewController = [storyBoard instantiateViewControllerWithIdentifier:kSignUpController];
    signUpViewController.slidingViewController = self.navigationController.slidingViewController;
    [self presentViewController:signUpViewController animated:YES completion:nil];
}


- (void)processSignInResult: (NSString *)errorMessage {
    if (errorMessage == nil) {
        [self switchToMainView];
    }
    else {
        [CLAToastManager showDefaultInfoToastWithText:errorMessage completionBlock:nil];
    }
}

- (void)switchToMainView {
    [((SlidingViewController *)self.navigationController.slidingViewController) switchToMainView];
}

@end
