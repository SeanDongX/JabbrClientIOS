//
//  CLASignUpViewController.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignUpViewController.h"
#import "CLANotificationHandler.H"

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
    [self setButtonBorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CLANotificationHandler *notificationHandler = [[CLANotificationHandler alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:notificationHandler selector:@selector(keyboardWillShow:withView:) name:UIKeyboardWillShowNotification object:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:notificationHandler selector:@selector(keyboardWillHide:withView:) name:UIKeyboardWillHideNotification object:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setButtonBorder {
    [[self.signInButton layer] setCornerRadius:5.0f];
    [[self.signInButton layer] setMasksToBounds:YES];
    [[self.signInButton layer] setBorderWidth:1.0f];
    [[self.signInButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    [[self.signUpButton layer] setCornerRadius:5.0f];
    [[self.signUpButton layer] setMasksToBounds:YES];
    [[self.signUpButton layer] setBorderWidth:1.0f];
    [[self.signUpButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
}

#pragma mark - 
#pragma mark Event Handlers

- (IBAction)signUpClicked:(id)sender {
    
}

- (IBAction)signInClicked:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
