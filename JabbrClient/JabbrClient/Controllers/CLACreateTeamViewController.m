//
//  CLACreateTeamViewController.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLACreateTeamViewController.h"

// Util
#import "Constants.h"
#import "CLANotificationManager.h"
#import "UserDataManager.h"
#import "Masonry.h"

// Menu
#import "UIViewController+ECSlidingViewController.h"

// Services
#import "CLAWebApiClient.h"
#import "CLAAzureHubPushNotificationService.h"
#import "SlidingViewController.h"

@interface CLACreateTeamViewController ()

@property(weak, nonatomic) IBOutlet UITextField *teamNameTextField;

@property(weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;

@property(weak, nonatomic) IBOutlet UIView *ScrollViewContentView;
@end

@implementation CLACreateTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextFields];
    [self setupNavBar];
    self.teamNameTextField.delegate = self;
    [self adjustScrollViewContentConstraint];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self redeemInvitationIfNeeded];
}

- (void)adjustScrollViewContentConstraint {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self.ScrollViewContentView
         mas_makeConstraints:^(MASConstraintMaker *make) {
             make.centerX.equalTo(self.view.mas_centerX);
         }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTextFields {
    self.teamNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inviteCodeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = NSLocalizedString(@"Pick Your Team", nil);
    [navBar setItems:@[ navItem ]];
    
    UIBarButtonItem *signOutButton =
    [[UIBarButtonItem alloc] initWithImage:[Constants signOutImage]
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(signOut)];
    signOutButton.tintColor = [UIColor whiteColor];
    navItem.rightBarButtonItem = signOutButton;
    
    [self.view addSubview:navBar];
}

#pragma mark -
#pragma mark Public Methods

- (void)redeemInvitation:(NSString *)invitationId  {
    self.inviteCodeTextField.text = invitationId;
    [UserDataManager cacheObject:nil forKey:kinvitationId];
    
    [CLANotificationManager showText: NSLocalizedString(@"Loading...", nil)
                   forViewController:self
                            withType:CLANotificationTypeMessage];
    
    CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
    __weak __typeof(&*self) weakSelf = self;
    
    [apiClient joinTeam:invitationId
      completionHandler:^(CLATeam *team, NSString *errorMessage) {
	         __strong __typeof(&*weakSelf) strongSelf = weakSelf;
	         [strongSelf processTeamRequestResult:team withErrorMessage:errorMessage];
      }];
}

#pragma mark -
#pragma mark Event Handlers

- (IBAction)createTeamClicked:(id)sender {
    NSString *teamName = self.teamNameTextField.text;
    
    if (teamName == nil || teamName.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"Oh, an empty team name. That will not work.",
                                    nil)
         forViewController:self
         withType:CLANotificationTypeError];
    } else if (teamName.length > kTeamNameMaxLength) {
        [CLANotificationManager
         showText:[NSString
                   stringWithFormat:NSLocalizedString(
                                                      @"Sorry, but we will need "
                                                      @"you to keep you team "
                                                      @"name less than %d "
                                                      @"characters.",
                                                      nil),
                   kTeamNameMaxLength]
         forViewController:self
         withType:CLANotificationTypeError];
    } else {
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        __weak __typeof(&*self) weakSelf = self;
        
        [apiClient createTeam:teamName
            completionHandler:^(CLATeam *team, NSString *errorMessage) {
                __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                [strongSelf processTeamRequestResult:team withErrorMessage:errorMessage];
            }];
    }
}

- (IBAction)joinTeamButtonClicked:(id)sender {
    NSString *invitationId = self.inviteCodeTextField.text;
    if (invitationId == nil || invitationId.length == 0) {
        
        [CLANotificationManager showText: NSLocalizedString(@"Oh, an empty invitation code. That will not work.", nil)
                       forViewController:self
                                withType:CLANotificationTypeWarning];
    } else {
        [self redeemInvitation: invitationId];
    }
}

#pragma mark -
#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    
    NSString *regex = @"[^-A-Za-z0-9]";
    NSPredicate *textTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([textTest evaluateWithObject:string]) {
        NSString *newString =
        [textField.text stringByReplacingCharactersInRange:range
                                                withString:@"-"];
        self.teamNameTextField.text = newString;
        
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [((SlidingViewController *)self.slidingViewController) switchToMainView];
    }
}
#pragma mark -
#pragma mark Private Methods
- (void)redeemInvitationIfNeeded {
    NSString *invitatationId = [UserDataManager getCachedObjectForKey:kinvitationId];
    if (invitatationId) {
        [self redeemInvitation:invitatationId];
    }
}

-(void)processTeamRequestResult:(CLATeam *)team withErrorMessage:(NSString *)errorMessage {
    [CLANotificationManager dismiss];
    [UserDataManager cacheTeam:team];
    
    if (errorMessage == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"You are now a member of team %@", nil), team.name]
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Jump In", nil), nil];
        [alert show];
        [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
    } else {
        [CLANotificationManager showText:errorMessage
                       forViewController:self
                                withType:CLANotificationTypeError];
    }
}

- (void)signOut {
    [UserDataManager signOut];
    [[CLAAzureHubPushNotificationService sharedInstance] unregisterDevice];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [self switchToSignInView];
}

- (void)switchToSignInView {
    SlidingViewController *slidingViewController =
    (SlidingViewController *)self.slidingViewController;
    [slidingViewController switchToSignInView];
}

- (void)switchToMainView {
    SlidingViewController *slidingViewController =
    (SlidingViewController *)self.slidingViewController;
    [slidingViewController switchToMainView];
}
@end
