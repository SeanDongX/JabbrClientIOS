//
//  CLASignUpViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignUpViewController.h"

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
    
}

- (IBAction)signInClicked:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
