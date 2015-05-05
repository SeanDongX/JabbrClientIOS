//
//  SignInViewController.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "SignInViewController.h"
#import "AuthManager.h"
#import "UIViewController+ECSlidingViewController.h"
#import "Constants.h"
#import "SlidingViewController.h"
#import "CLASignUpViewController.h"
#import "CRToast.h"
#import "MBProgressHUD.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (nonatomic, strong) NSMutableDictionary *toasOptions;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toasOptions = [Constants toasOptions].mutableCopy;
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
    self.toasOptions[kCRToastImageKey] = [Constants infoIconImage];
    
    NSString *username = [self.usernameTextField text];
    NSString *password = [self.passwordTextField text];
    
    if (username == nil || username.length == 0) {
        
        [self.toasOptions setObject:@"Did you forget your username?" forKey:kCRToastTextKey];
        [CRToastManager showNotificationWithOptions:self.toasOptions
                                    completionBlock:nil];
        
        return;
    }
    
    if (password == nil || password.length == 0) {
        
        [self.toasOptions setObject:@"OK, that password won't work." forKey:kCRToastTextKey];
        [CRToastManager showNotificationWithOptions:self.toasOptions
                                    completionBlock:nil];
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    [[AuthManager sharedInstance]signInWithUsername:username
                                           password:password
                                         completion:^(NSError *error){
                                             
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             [self processSignInResult:error];
    }];
    
}

- (IBAction)signUpClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLASignUpViewController *signUpViewController = [storyBoard instantiateViewControllerWithIdentifier:kSignUpController];
    [self presentViewController:signUpViewController animated:TRUE completion:nil];
}


- (void)processSignInResult: (NSError *)error {
    if (!error) {
        [self switchToMainView];
    }
    else {
        NSString *errorMessage = [error.userInfo objectForKey:kErrorDescription];
        
        if (errorMessage == nil) {
            errorMessage = kErrorMsgSignInFailureUnknown;
        }
        
        [self.toasOptions setObject:errorMessage forKey:kCRToastTextKey];
        
        [CRToastManager showNotificationWithOptions:self.toasOptions
                                    completionBlock:nil];
        
        NSLog(@"Sign in error, error domain: %@, error code: %ld", error.domain, (long)error.code);
    }
}

- (void)switchToMainView {
    [((SlidingViewController *)self.navigationController.slidingViewController) switchToMainView];
}

@end
