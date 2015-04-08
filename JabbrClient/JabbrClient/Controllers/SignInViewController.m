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

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setButtonBorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark - Keyboard Movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

#pragma mark -
#pragma mark - Set Button

- (void)setButtonBorder {
    [[self.signInButton layer] setCornerRadius:5.0f];
    [[self.signInButton layer] setMasksToBounds:YES];
    [[self.signInButton layer] setBorderWidth:1.0f];
    [[self.signInButton layer] setBorderColor:[UIColor whiteColor].CGColor];
}


#pragma mark -
#pragma mark - Event Handler
- (IBAction)signInClicked:(id)sender {
    //TOOD: check user name and password
    
    [[AuthManager sharedInstance]signInWithUsername:[self.usernameTextField text]
                                           password:[self.passwordTextField text]
                                         completion:^(NSError *error){
        [self processSignInResult:error];
    }];
    
}

- (void)processSignInResult: (NSError *)error {
    if (!error) {
        [self switchToMainView];
    }
    else {
        //TODO: show error on UI
        NSLog(@"Sign in error, error domain: %@, error code: %ld", error.domain, (long)error.code);
    }
}

- (void)switchToMainView {
    [((SlidingViewController *)self.navigationController.slidingViewController) switchToMainView];
}

@end
