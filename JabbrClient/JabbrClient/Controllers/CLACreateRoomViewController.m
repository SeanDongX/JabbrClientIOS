//
//  CLACreateRoomViewController.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLACreateRoomViewController.h"
#import "Constants.h"
#import "CLANotificationManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"

@interface CLACreateRoomViewController ()

@property (weak, nonatomic) IBOutlet UIView *rootScrollView;
@property (weak, nonatomic) IBOutlet UIView *upperViewContainer;
@property (weak, nonatomic) IBOutlet UIView *lowerViewContainer;

@property (weak, nonatomic) IBOutlet UILabel *createTopicLabel;
@property (weak, nonatomic) IBOutlet UITextField *topicNameTextField;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) BOOL isFiltered;

@property (strong, nonatomic) NSMutableArray<CLARoom *> *tableItems;
@property (strong, nonatomic) NSMutableArray<CLARoom *> *filteredtableItems;

@end

//TODO: open room when crated or joined
@implementation CLACreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUi];
    [self setupData];
}

- (void)setupUi {
    [self setupNavBar];
    [self setupFormItem];
    [self updateConstraints];
    self.topicNameTextField.delegate = self;
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
    navItem.title = NSLocalizedString(@"Create Topic", nil);
    [navBar setItems:@[ navItem ]];
    
    UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.leftBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}

- (void)setupFormItem {
    switch (self.roomType) {
        case RoomTypePulbic:
            self.createTopicLabel.text = NSLocalizedString(@"Create Public Topic", nil);
            break;
            
        case RoomTypePrivate:
            self.createTopicLabel.text = NSLocalizedString(@"Create Pirvate Topic", nil);
            break;
            
        default:
            break;
    }
}

- (void)updateConstraints {
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self.rootScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(screenHeight);
    }];
    
    if (self.roomType == RoomTypeDirect) {
        [self.upperViewContainer setHidden:YES];
        [self.upperViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStatusBarHeight);
        }];
        
        [self.lowerViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            //TODO: fix lower container height
            make.height.mas_equalTo(screenHeight - kStatusBarHeight);
        }];
    }
    else {
        [self.lowerViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(screenHeight - 300);
        }];
    }
}

- (void)setupData {
    NSArray<CLARoom *> *notJoinedRooms = [[[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam] getNotJoinedRooms];
    
    self.tableItems = [NSMutableArray array];
    self.filteredtableItems = [NSMutableArray array];
    for (CLARoom *room in notJoinedRooms) {
        
        switch (self.roomType) {
            case RoomTypePulbic:
                if (room.isPrivate == NO) {
                    [self.tableItems addObject:room];
                    [self.filteredtableItems addObject:room];
                }
                break;
                
            case RoomTypePrivate:
                if (room.isPrivate != NO && room.isDirectRoom == NO) {
                    [self.tableItems addObject:room];
                    [self.filteredtableItems addObject:room];
                }
                break;
                
            case RoomTypeDirect:
                if (room.isDirectRoom != NO) {
                    [self.tableItems addObject:room];
                    [self.filteredtableItems addObject:room];
                }
                break;
                
            default:
                break;
        }
    }
}

- (void)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goButtonClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self invokeCreateTopic: self.topicNameTextField.text withRoomType:self.roomType];
}

- (void)invokeCreateTopic:(NSString *)name withRoomType:(RoomType)roomType {
    CLASignalRMessageClient *messageClient = [CLASignalRMessageClient sharedInstance];
    
    __weak __typeof(&*self) weakSelf = self;
    
    [messageClient createRoomWithType:roomType
                                 name:name
                      completionBlock:^(NSError *error) {
                          __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                          
                          if (error == nil) {
                              [strongSelf dismissViewControllerAnimated:YES completion:nil];
                          } else {
                              
                              // TODO: define error code
                              NSString *errorDescription =
                              [error.userInfo objectForKey:NSLocalizedDescriptionKey];
                              
                              if (errorDescription != nil && errorDescription.length > 0) {
                                  [CLANotificationManager showText:errorDescription
                                                 forViewController:strongSelf
                                                          withType:CLANotificationTypeError];
                              } else {
                                  [CLANotificationManager
                                   showText:NSLocalizedString(@"Oh, something went "
                                                              @"wrong. Let's try "
                                                              @"it again.",
                                                              nil)
                                   forViewController:strongSelf
                                   withType:CLANotificationTypeError];
                              }
                          }
                          
                          [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
                          
                      }];
}

#pragma mark -
#pragma Search Bar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    if (text.length == 0) {
        self.isFiltered = FALSE;
    } else {
        self.isFiltered = TRUE;
        [self filterContentForSearchText:text];
    }
    
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *resultPredicate =
    [NSPredicate predicateWithFormat:@"displayName contains[c] %@", searchText];
    self.filteredtableItems = [self.tableItems filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.filteredtableItems.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    CLARoom *room = self.filteredtableItems[indexPath.row];
    cell.textLabel.text = room.displayName;
    
    cell.textLabel.textColor = [Constants mainThemeContrastColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants highlightColor];
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

#pragma mark - Table Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 0;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navController = nil;
    CLARoom *selectedRoom = self.filteredtableItems[indexPath.row];
    
    if (self.roomType == RoomTypeDirect) {
        NSString *roomName = [selectedRoom.displayName substringFromIndex:1];
        [self invokeCreateTopic:roomName withRoomType:self.roomType];
    }
    else {
        [[CLASignalRMessageClient sharedInstance] joinRoom:selectedRoom.name];
        [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
        [self dismissViewControllerAnimated:YES completion:nil];
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
        self.topicNameTextField.text = newString;
        
        return NO;
    }
    
    return YES;
}

@end
