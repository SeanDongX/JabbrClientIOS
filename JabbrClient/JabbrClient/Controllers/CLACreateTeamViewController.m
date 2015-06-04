//
//  CLACreateTeamViewController.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLACreateTeamViewController.h"

//Util
#import "Constants.h"
#import "CLAToastManager.h"
#import "AuthManager.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"

//API Client
#import "CLAWebApiClient.h"

@interface CLACreateTeamViewController ()

@property (weak, nonatomic) IBOutlet UITextField *teamNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;

@end

@implementation CLACreateTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    self.teamNameTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kStatusBarHeight)];
    navBar.barTintColor = [Constants mainThemeColor];
    navBar.translucent = NO;
    navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = NSLocalizedString(@"Pick Your Team", nil);
    [navBar setItems:@[navItem]];
    
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc] initWithImage: [Constants signOutImage]
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(signOut)];
    signOutButton.tintColor = [UIColor whiteColor];
    navItem.rightBarButtonItem = signOutButton;
    
    [self.view addSubview:navBar];
}

#pragma mark -
#pragma mark Event Handlers

- (IBAction)createTeamClicked:(id)sender {
    NSString *teamName = self.teamNameTextField.text;
    
    if ( teamName == nil || teamName.length == 0) {
        
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"Oh, an empty name. That will not work.", nil) completionBlock:nil];
    }
    else if (teamName.length > kTeamNameMaxLength) {
        
        [CLAToastManager showDefaultInfoToastWithText:[NSString stringWithFormat:NSLocalizedString(@"Sorry, but we will need you to keep you team name less than %d characters.", nil), kTeamNameMaxLength ]completionBlock:nil];
    }
    else {
        
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        __weak __typeof(&*self)weakSelf = self;
        
        [apiClient createTeam:teamName completionHandler: ^(NSString *errorMessage){
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            
            if (errorMessage == nil) {
                [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
                [strongSelf dismissViewControllerAnimated:YES completion: nil];
            }
            else {
                
                [CLAToastManager showDefaultInfoToastWithText:errorMessage completionBlock:nil];
            }
        
        }];
    }
    
}

- (IBAction)joinTeamButtonClicked:(id)sender {
    NSString *inviteCode = self.inviteCodeTextField.text;
    
    if ( inviteCode == nil || inviteCode.length == 0) {
        
        [CLAToastManager showDefaultInfoToastWithText:NSLocalizedString(@"Oh, an empty invitation code. That will not work.", nil) completionBlock:nil];
    }
    else {
        
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        __weak __typeof(&*self)weakSelf = self;
        
        [apiClient joinTeam:inviteCode completionHandler: ^(NSString *errorMessage){
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            if (errorMessage == nil) {
                [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
                [strongSelf dismissViewControllerAnimated:YES completion: nil];
            }
            else {
                
                [CLAToastManager showDefaultInfoToastWithText:errorMessage completionBlock:nil];
            }
            
        }];
    }
}

#pragma mark -
#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *regex = @"[^-A-Za-z0-9]";
    NSPredicate *textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([textTest evaluateWithObject:string]){
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:@"-"];
        self.teamNameTextField.text = newString;
        
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Private Methods

- (void)signOut {
    [[AuthManager sharedInstance] signOut];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [self switchToSignInView];
}

- (void)switchToSignInView {
    SlidingViewController *slidingViewController = (SlidingViewController *)self.slidingViewController;
    [slidingViewController switchToSignInView];
}

@end
