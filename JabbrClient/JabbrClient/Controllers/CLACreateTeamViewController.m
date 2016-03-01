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

@property(weak, nonatomic) IBOutlet UITextField *teamNameCreateTextField;
@property(weak, nonatomic) IBOutlet UITextField *teamNameJoinTextField;

@property (weak, nonatomic) IBOutlet UIView *contentBottomView;
@property(strong, nonatomic) UIAlertView *alertView;

@end

@implementation CLACreateTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextFields];
    [self setupNavBar];
    self.teamNameCreateTextField.delegate = self;
    self.teamNameJoinTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self redeemInvitationIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTextFields {
    self.teamNameCreateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.teamNameJoinTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = NSLocalizedString(@"Pick Your Team", nil);
    [navBar setItems:@[ navItem ]];
    
    UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage]
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(close)];
    closeButton.tintColor = [UIColor whiteColor];
    navItem.rightBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}

#pragma mark -
#pragma mark Public Methods

- (void)redeemInvitation:(NSString *)invitationId  {
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
    NSString *teamName = self.teamNameCreateTextField.text;
    if ([self isTeamnameValid: teamName] == YES) {
        
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        __weak __typeof(&*self) weakSelf = self;
        
        [apiClient createTeam:teamName
            completionHandler:^(CLATeam *team, NSString *errorMessage) {
                __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                [strongSelf processTeamRequestResult:team withErrorMessage:errorMessage];
            }];
    }
}

- (IBAction)requestJoinTeamButtonClicked:(id)sender {
    NSString *joinTeamName = self.teamNameJoinTextField.text;
    if ([self isTeamnameValid: joinTeamName] == YES) {
        
        CLAWebApiClient *apiClient = [CLAWebApiClient sharedInstance];
        __weak __typeof(&*self) weakSelf = self;
        
        [apiClient requestJoinTeam:joinTeamName
                 completionHandler:^(NSString *errorMessage) {
                     __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                     if (errorMessage) {
                         [CLANotificationManager
                          showText:errorMessage
                          forViewController:strongSelf
                          withType:CLANotificationTypeError];
                     }
                     else {
                         [CLANotificationManager
                          showText:NSLocalizedString(@"Your request has been sent. Please check your email for team administrator's approval", nil)
                          forViewController:strongSelf
                          withType:CLANotificationTypeMessage];
                     }
                 }];
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
        textField.text = newString;
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.teamNameJoinTextField) {
        [self raiseContent];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.teamNameCreateTextField) {
        [self.teamNameJoinTextField becomeFirstResponder];
        [self raiseContent];
    } else {
        [self.teamNameCreateTextField becomeFirstResponder];
        [self restoreContent];
    }
    return YES;
}

- (void)raiseContent {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.contentBottomView.frame;
        f.origin.y = 0;
        [self.contentBottomView setFrame:f];
    } completion:^(BOOL finished) {
    }];
}

- (void)restoreContent {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.contentBottomView.frame;
        f.origin.y = f.size.height;
        [self.contentBottomView setFrame:f];
    } completion:^(BOOL finished) {
    }];
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

- (BOOL)isTeamnameValid:(NSString *)teamName {
    BOOL returnValue = YES;
    if (teamName == nil || teamName.length == 0) {
        [CLANotificationManager
         showText:NSLocalizedString(
                                    @"Oh, an empty team name. That will not work.",
                                    nil)
         forViewController:self
         withType:CLANotificationTypeError];
        
        returnValue = NO;
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
        
        returnValue = NO;
    }
    
    return returnValue;
}

- (void)redeemInvitationIfNeeded {
    NSString *invitatationId = [UserDataManager getCachedObjectForKey:kinvitationId];
    if (invitatationId) {
        [self redeemInvitation:invitatationId];
    }
}

-(void)processTeamRequestResult:(CLATeam *)team withErrorMessage:(NSString *)errorMessage {
    if (errorMessage == nil) {
        [UserDataManager cacheTeam:team];
        [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
        [self showAlertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"You are now a member of team %@", nil), team.name]
                 confirmButtonText: NSLocalizedString(@"Jump In", nil)];
        
    } else {
        [CLANotificationManager dismiss];
        [CLANotificationManager showText:errorMessage
                       forViewController:self
                                withType:CLANotificationTypeError];
    }
}

- (void)showAlertWithMessage:(NSString *)message confirmButtonText:(NSString *)buttontext {
    self.alertView = [[UIAlertView alloc] initWithTitle:message
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:buttontext, nil];
    [self.alertView show];
}

- (void)close {
    if (self.sourceViewIdentifier) {
        [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:self.sourceViewIdentifier];
    }
    else {
        [self signOut];
    }
}

- (void)signOut {
    [UserDataManager signOut];
    [[CLAAzureHubPushNotificationService sharedInstance] unregisterDevice];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [self switchToSignInView];
}

- (void)switchToSignInView {
    [((SlidingViewController *)self.slidingViewController) switchToSignInView];
}

- (void)switchToMainView {
    [((SlidingViewController *)self.slidingViewController) switchToMainView];
}
@end
