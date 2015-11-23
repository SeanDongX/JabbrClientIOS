//
//  CLACreateTopicViewController
//  Collara
//
//  Created by Sean on 22/11/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLACreateTopicViewController.h"

#import "Constants.h"

//Utils
#import "AuthManager.h"
#import "MBProgressHUD.h"
#import "CLANotificationManager.h"

//Data Model
#import "CLASignalRMessageClient.h"
#import "CLAUser.h"

@interface CLACreateTopicViewController ()

@property (strong, nonatomic) XLFormRowDescriptor *topicRow;

@end

@implementation CLACreateTopicViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initForm];
    }
    return self;
}

- (instancetype)initWithRoomType:(RoomType )roomType {
    self = [super init];
    if (self) {
        self.roomType = roomType;
        [self initForm];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),
                                                        kStatusBarHeight)];
    navBar.barTintColor = [Constants mainThemeColor];
    navBar.translucent = NO;
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = [self getFormTitle];
    [navBar setItems:@[ navItem ]];
    
    UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.leftBarButtonItem = closeButton;
    
    
    UIBarButtonItem *goButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Go", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(goButtonClicked:)];
    
    [goButton setTintColor:[UIColor whiteColor]];
    navItem.rightBarButtonItem = goButton;
    
    [self.view addSubview:navBar];
}

#pragma mark --
#pragma mark - Form Setup

- (void)initForm {
    self.form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *placeHolderSection = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:placeHolderSection];
    
    XLFormSectionDescriptor *placeHolderSection2 = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:placeHolderSection2];
    
    
    XLFormSectionDescriptor *topicSection = [self getTopicSection];
    self.topicRow = topicSection.formRows[0];
    [self.form addFormSection: topicSection];
}

- (NSString *)getFormTitle {
    switch (self.roomType) {
        case RoomTypePulbic:
        default:
            return NSLocalizedString(@"Create Public Topic", nil);
            
        case RoomTypePrivate:
            return NSLocalizedString(@"Create Private Topic", nil);
            
        case RoomTypeDirect:
            return NSLocalizedString(@"Send Direct Message", nil);
    }
}

- (XLFormSectionDescriptor *)getTopicSection {
    switch (self.roomType) {
        case RoomTypePulbic:
        case RoomTypePrivate:
        default:
            return [self getPublicOrPrivateRoomSection];
            
        case RoomTypeDirect:
            return [self getDirectRoomSection];
    }
}

- (XLFormSectionDescriptor *)getPublicOrPrivateRoomSection {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    section.title = NSLocalizedString(@"Only letters and \"-\" please", nil);
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:kTopicName
                                                                     rowType:XLFormRowDescriptorTypeText
                                                                       title:NSLocalizedString(@"Name", nil)];
    row.required = YES;
    [section addFormRow:row];
    return section;
}


- (XLFormSectionDescriptor *)getDirectRoomSection {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    section.title = NSLocalizedString(@"Select a team member", nil);
    
    XLFormRowDescriptor *row;
    
    NSArray<CLAUser> *allUsers =
    [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam]
    .users;
    
    NSString *currentUserName = [[AuthManager sharedInstance] getUsername];
    NSMutableArray *userNameArray = [NSMutableArray array];
    for (CLAUser *user in allUsers) {
        if (![currentUserName isEqualToString:user.name]) {
            [userNameArray addObject: user.name];
        }
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTopicName rowType:XLFormRowDescriptorTypePicker];
    
    row.selectorOptions = userNameArray;
    row.value = userNameArray[0];
    [section addFormRow:row];
    
    return section;
}

#pragma --
#pragma Event Handlers

- (void)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goButtonClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *topic = self.topicRow.value;
    
    CLASignalRMessageClient *messageClient =
    [CLASignalRMessageClient sharedInstance];
    
    __weak __typeof(&*self) weakSelf = self;
    
    [messageClient createRoomWithType:self.roomType
                                 name:topic
                      completionBlock:^(NSError *error) {
                          if (error == nil) {
                              __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                              
                              [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
                              [strongSelf dismissViewControllerAnimated:YES completion:nil];
                          } else {
                              
                              // TODO: define error code
                              NSString *errorDescription =
                              [error.userInfo objectForKey:NSLocalizedDescriptionKey];
                              
                              if (errorDescription != nil && errorDescription.length > 0) {
                                  [CLANotificationManager showText:errorDescription
                                                 forViewController:self
                                                          withType:CLANotificationTypeError];
                              } else {
                                  [CLANotificationManager
                                   showText:NSLocalizedString(@"Oh, something went "
                                                              @"wrong. Let's try "
                                                              @"it again.",
                                                              nil)
                                   forViewController:self
                                   withType:CLANotificationTypeError];
                              }
                          }
                          
                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                          
                      }];
}

#pragma mark -
#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    
    if (self.roomType == RoomTypeDirect) {
        return YES;
    }
    
    NSString *regex = @"[^-A-Za-z0-9]";
    NSPredicate *textTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([textTest evaluateWithObject:string]) {
        NSString *newString =
        [textField.text stringByReplacingCharactersInRange:range
                                                withString:@"-"];
        self.topicRow.value = newString;
        
        return NO;
    }
    
    return YES;
}

@end
