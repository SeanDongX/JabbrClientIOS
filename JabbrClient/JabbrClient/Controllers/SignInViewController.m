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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setButtonBorder {
    [[self.signInButton layer] setCornerRadius:5.0f];
    [[self.signInButton layer] setMasksToBounds:YES];
    [[self.signInButton layer] setBorderWidth:1.0f];
    [[self.signInButton layer] setBorderColor:[UIColor whiteColor].CGColor];
}

#pragma -
#pragma Event Handler
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
