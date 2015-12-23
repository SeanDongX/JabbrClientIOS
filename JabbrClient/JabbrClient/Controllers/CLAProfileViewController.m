//
//  CLAProfileViewController.m
//  Collara
//
//  Created by Sean on 22/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLAProfileViewController.h"
#import "Constants.h"
#import "CLASignalRMessageClient.h"
#import "XLForm.h"
#import "AuthManager.h"

#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"
#import "CLAAzureHubPushNotificationService.h"

@interface CLAProfileViewController ()

@end

@implementation CLAProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.form = [self getForm];
}

- (void)setupView {
    self.tableView.backgroundColor = [Constants backgroundColor];
    [self setupNavBar];
}

- (void)setupNavBar {
    self.navigationController.navigationBar.topItem.title = @"Profile";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu)];
    [menuButton setImage:[Constants menuIconImage]];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    UIBarButtonItem *signoutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign Out", nil) style:UIBarButtonItemStylePlain target:self action:@selector(signout)];
    self.navigationItem.rightBarButtonItem = signoutButton;
}

- (void)openMenu {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)signout {
    [[AuthManager sharedInstance] signOut];
    [[CLAAzureHubPushNotificationService sharedInstance] unregisterDevice];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [[CLASignalRMessageClient sharedInstance].dataRepository deleteData];
    // TODO:MessageClient clear data repository
    [self switchToSignInView];
}

- (void)switchToSignInView {
    
    SlidingViewController *slidingViewController =
    (SlidingViewController *)self.navigationController.slidingViewController;
    
    [slidingViewController clearControllerCache];
    [slidingViewController switchToSignInView];
}


- (XLFormDescriptor *)getForm {
    XLFormDescriptor *form = [XLFormDescriptor
                              formDescriptorWithTitle:NSLocalizedString(@"Settings", nil)];
    [form addFormSection:[self getTeamSection]];
    return form;
}

- (XLFormSectionDescriptor *)getTeamSection {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor
                                        formSectionWithTitle:NSLocalizedString(@"Team", nil)];
    
    XLFormRowDescriptor *row =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"TeamSelector"
                                          rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                            title:NSLocalizedString(@"Team", nil)];
    
    NSMutableArray *options = [NSMutableArray array];
    NSArray<CLATeamViewModel *> *teams = [[CLASignalRMessageClient sharedInstance].dataRepository getTeams];
    
    for(CLATeamViewModel *teamViewModel in teams) {
        if (teamViewModel.team.name != nil) {
            [options addObject: [XLFormOptionsObject formOptionsObjectWithValue:teamViewModel.team.name displayText:teamViewModel.team.name]];
        }
        
        if ([teamViewModel.team.name isEqualToString:[[AuthManager sharedInstance] getTeamName]]) {
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:teamViewModel.team.name displayText:teamViewModel.team.name];
        }
    }
    
    row.selectorOptions = options;
    [section addFormRow: row];
    
    return section;
}
@end
