//
//  CLAProfileViewController.m
//  Collara
//
//  Created by Sean on 22/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLAProfileViewController.h"
#import "Constants.h"
#import "XLForm.h"
#import "UserDataManager.h"

#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"
#import "CLATeamViewModel.h"
#import "CLASignalRMessageClient.h"
#import "CLAAzureHubPushNotificationService.h"

@interface CLAProfileViewController ()

@property (nonatomic) BOOL rowValueSetProgramatically;

@end

@implementation CLAProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.backItem.hidesBackButton = YES;
    self.form = [self getForm];
}

- (void)setupView {
    self.tableView.backgroundColor = [Constants backgroundColor];
    [self setupNavBar];
}

- (void)setupNavBar {
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Settings", nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *menuButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(openMenu)];
    [menuButton setImage:[Constants menuIconImage]];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    UIBarButtonItem *signoutButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign Out", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(signout)];
    self.navigationItem.rightBarButtonItem = signoutButton;
}

- (void)openMenu {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)signout {
    [[UserDataManager sharedInstance] signOut];
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
    [form addFormSection:[self getAccountSection]];
    [form addFormSection:[self getTeamSection]];
    return form;
}

- (XLFormSectionDescriptor *)getAccountSection {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor
                                        formSectionWithTitle:NSLocalizedString(@"Account", nil)];
    
    XLFormRowDescriptor *username =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"Username"
                                          rowType:XLFormRowDescriptorTypeInfo
                                            title:NSLocalizedString(@"Username", nil)];
    username.value = [[UserDataManager sharedInstance] getUsername];
    [section addFormRow:username];
    
    XLFormRowDescriptor *email =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"Email"
                                          rowType:XLFormRowDescriptorTypeInfo
                                            title:NSLocalizedString(@"Email", nil)];
    //TODO: get email
    email.value = @"abc@gmail.com";
    [section addFormRow:email];
    
    return section;
}

- (XLFormSectionDescriptor *)getTeamSection {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor
                                        formSectionWithTitle:NSLocalizedString(@"Team", nil)];
    
    NSArray<CLATeamViewModel *> *teams = [[CLASignalRMessageClient sharedInstance].dataRepository getTeams];
    
    XLFormRowDescriptor *row =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"TeamSelector"
                                          rowType:XLFormRowDescriptorTypeSelectorActionSheet
                                            title:NSLocalizedString(@"Switch Team", nil)];
    
    NSMutableArray *options = [NSMutableArray array];
    
    for(CLATeamViewModel *teamViewModel in teams) {
        if (teamViewModel.team.name != nil) {
            [options addObject: [XLFormOptionsObject formOptionsObjectWithValue:teamViewModel.team.name displayText:teamViewModel.team.name]];
        }
        
        if ([teamViewModel.team.name isEqualToString:[[UserDataManager sharedInstance] getTeamName]]) {
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:teamViewModel.team.name displayText:teamViewModel.team.name];
        }
        
    }
    
    row.selectorOptions = options;
    [section addFormRow:row];
    return section;
}

- (void)selectTeam:(XLFormRowDescriptor *)sender withValue:(id)newValue {
    
    if (self.rowValueSetProgramatically != NO) {
        return;
    }
    
    if (![newValue  isEqual: @1]) {
        self.rowValueSetProgramatically = YES;
        sender.value = @1;
    }
    else {
        for(XLFormRowDescriptor *row in sender.sectionDescriptor.formRows) {
            if (row.tag != sender.tag) {
                row.value = @0;
            }
        }
    }
}
@end
