//
//  CLAInviteTopicUserViewController.m
//  Collara
//
//  Created by Sean on 24/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLATopicInfoViewController.h"

// Utils
#import "CLASignalRMessageClient.h"
#import "Constants.h"
#import "CLANotificationManager.h"

#import "XLForm.h"

NSString *const kTopicName = @"TopicName";
NSString *const kLeaveTopicButton = @"LeaveTopicButton";
NSString *const kSendInviteButton = @"SendInviteButton";
NSString *const kInvitePrefix = @"Invite-";

@interface CLATopicInfoViewController ()

@property(strong, nonatomic) CLARoomViewModel *roomViewModel;

@end

@implementation CLATopicInfoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.form = [self getForm];
    }
    return self;
}

- (instancetype)initWithRoom:(CLARoomViewModel *)roomViewModel {
    self = [super init];
    if (self) {
        self.roomViewModel = roomViewModel;
        self.form = [self getForm];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.tableView.backgroundColor = [Constants backgroundColor];
    [self setupNavBar];
}

- (void)setupNavBar {
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (XLFormDescriptor *)getForm {
    XLFormDescriptor *form = [XLFormDescriptor
                              formDescriptorWithTitle:NSLocalizedString(@"Topic Settings", nil)];
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    NSArray<CLAUser *> *allUsers =
    [[CLASignalRMessageClient sharedInstance].dataRepository getCurrentOrDefaultTeam]
    .users;
    NSMutableArray<CLAUser *> *notMembers = [NSMutableArray array];
    [notMembers addObjectsFromArray:allUsers];
    
    section = [XLFormSectionDescriptor
               formSectionWithTitle:NSLocalizedString(@"Topic", nil)];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor
           formRowDescriptorWithTag:kTopicName
           rowType:XLFormRowDescriptorTypeName
           title:[self.roomViewModel.room getHandle]];
    row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor
           formRowDescriptorWithTag:kLeaveTopicButton
           rowType:XLFormRowDescriptorTypeButton
           title:NSLocalizedString(@"Leave", nil)];
    [row.cellConfig setObject:[Constants warningColor] forKey:kXLFormTextLabelColor];
    row.action.formSelector = @selector(leavelTopic:);
    [section addFormRow:row];
    
    if (self.roomViewModel && self.roomViewModel.users) {
        section = [XLFormSectionDescriptor
                   formSectionWithTitle:NSLocalizedString(@"Members", nil)];
        [form addFormSection:section];
        
        for (CLAUser *user in self.roomViewModel.users) {
            for (CLAUser *innerUser in allUsers) {
                if ([innerUser.name isEqualToString:user.name]) {
                    [notMembers removeObject:innerUser];
                    break;
                }
            }
            
            row = [XLFormRowDescriptor
                   formRowDescriptorWithTag:[user getHandle]
                   rowType:XLFormRowDescriptorTypeInfo
                   title:[user getHandle]];
            [section addFormRow:row];
        }
    }
    
    if (notMembers.count > 0) {
        section = [XLFormSectionDescriptor
                   formSectionWithTitle:NSLocalizedString(@"Select users to invite", nil)];
        [form addFormSection:section];
        
        for (CLAUser *user in notMembers) {
            row = [XLFormRowDescriptor
                   formRowDescriptorWithTag:
                   [NSString stringWithFormat:@"%@%@", kInvitePrefix, user.name]
                   rowType:XLFormRowDescriptorTypeBooleanSwitch
                   title:[user getHandle]];
            [section addFormRow:row];
        }
        
        [section addFormRow:row];
        
        row = [XLFormRowDescriptor
               formRowDescriptorWithTag:kSendInviteButton
               rowType:XLFormRowDescriptorTypeButton
               title:NSLocalizedString(@"Send Invite", nil)];
        [row.cellConfig setObject:[Constants highlightColor]
                           forKey:kXLFormTextLabelColor];
        row.action.formSelector = @selector(sendInvite:);
        [section addFormRow:row];
    }
    
    return form;
}

- (void)leavelTopic:(id)sender {
    [[CLASignalRMessageClient sharedInstance]
     leaveRoom:self.roomViewModel.room.name];
    [CLANotificationManager
     showText:NSLocalizedString(@"You will not receive notification "
                                @"about this topic any more.",
                                nil)
     forViewController:self
     withType:CLANotificationTypeMessage];
}

- (void)sendInvite:(id)sender {
    BOOL matchFound = false;
    
    NSArray *keys = self.formValues.allKeys;
    for (NSString *key in keys) {
        if ([key hasPrefix:kInvitePrefix]) {
            id value = [self.formValues objectForKey:key];
            if (value != [NSNull null] && [value boolValue]) {
                NSString *username =
                [key stringByReplacingOccurrencesOfString:kInvitePrefix
                                               withString:@""];
                
                if (username && username.length > 0) {
                    matchFound = true;
                    [[CLASignalRMessageClient sharedInstance]
                     inviteUser:username
                     inRoom:self.roomViewModel.room.name];
                }
            }
        }
    }
    
    if (matchFound) {
        [CLANotificationManager showText:NSLocalizedString(@"Invitation sent", nil)
                       forViewController:self
                                withType:CLANotificationTypeMessage];
    }
}
@end
