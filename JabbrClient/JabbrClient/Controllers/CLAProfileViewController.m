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
#import "CLASignalRMessageClient.h"
#import "CLAAzureHubPushNotificationService.h"
#import "CLARealmRepository.h"
#import "CLACreateTeamViewController.h"

@interface CLAProfileViewController ()

@property (nonatomic, strong) NSArray<CLATeam *> *teams;

@end

@implementation CLAProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.backItem.hidesBackButton = YES;
    self.teams = [[CLASignalRMessageClient sharedInstance].dataRepository getTeams];
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
    [UserDataManager signOut];
    [[CLAAzureHubPushNotificationService sharedInstance] unregisterDevice];
    [[CLASignalRMessageClient sharedInstance] disconnect];
    [[CLASignalRMessageClient sharedInstance].dataRepository deleteData];
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
    username.value = [UserDataManager getUsername];
    [section addFormRow:username];
    
    XLFormRowDescriptor *email =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"Email"
                                          rowType:XLFormRowDescriptorTypeInfo
                                            title:NSLocalizedString(@"Email", nil)];
    CLAUser *user = [UserDataManager getUser];
    email.value = user.email;
    [section addFormRow:email];
    
    return section;
}

- (XLFormSectionDescriptor *)getTeamSection {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor
                                        formSectionWithTitle:NSLocalizedString(@"Team", nil)];
    
    
    XLFormRowDescriptor *row =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"TeamSelector"
                                          rowType:XLFormRowDescriptorTypeSelectorPush
                                            title:NSLocalizedString(@"Switch Team", nil)];
    
    NSMutableArray *options = [NSMutableArray array];
    
    for(CLATeam *team in self.teams) {
        if (team.name != nil) {
            [options addObject: [XLFormOptionsObject formOptionsObjectWithValue:team.key displayText:team.name]];
        }
        
        if (team.key.integerValue > 0
            && team.key.integerValue == [UserDataManager getTeam].key.integerValue) {
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:team.key displayText:team.name];
        }
        
    }
    
    row.selectorOptions = options;
    [section addFormRow: row];
    
    typeof(self) __weak weakself = self;
    row.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor* __unused rowDescriptor) {
        [weakself switchTeam:newValue withOldValue:oldValue];
    };
    
    
    XLFormRowDescriptor *createOrJoinTeamRow =
    [XLFormRowDescriptor formRowDescriptorWithTag:@"CreateOrJoinTeam"
                                          rowType:XLFormRowDescriptorTypeButton
                                            title:NSLocalizedString(@"Create or join team", nil)];
    [createOrJoinTeamRow.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
    
    createOrJoinTeamRow.action.formBlock = ^(XLFormRowDescriptor *sender){
        [((SlidingViewController *)self.slidingViewController) switchToCreateTeamView:nil
                                                                 sourceViewIdentifier:kProfileNavigationController ];
    };
    
    [section addFormRow: createOrJoinTeamRow];
    return section;
}

- (void)switchTeam:(XLFormOptionsObject *)newValue withOldValue:(XLFormOptionsObject *)oldValue {
    if (!newValue || [newValue isKindOfClass:[NSNull class]] || [newValue.formValue integerValue] == [oldValue.formValue integerValue]) {
        return;
    }
    
    if ([newValue.formValue integerValue] > 0) {
        for (CLATeam *team in self.teams) {
            if (team.key.integerValue == [newValue.formValue integerValue]) {
                [UserDataManager cacheTeam:team];
                [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
            }
        }
    }
}

@end
