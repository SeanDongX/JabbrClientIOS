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
@interface CLACreateRoomViewController ()

@property (weak, nonatomic) IBOutlet UITextField *topicLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) BOOL isFiltered;

@property (strong, nonatomic) NSMutableArray<CLARoom> *tableItems;
@property (strong, nonatomic) NSMutableArray<CLARoom> *filteredtableItems;

@end

@implementation CLACreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    [self setupData];
    self.topicLabel.delegate = self;
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

- (void)setupData {
    
    self.tableItems = [[CLASignalRMessageClient sharedInstance].dataRepository getDefaultTeam].getNotJoinedRooms;
    
    self.filteredtableItems = [NSMutableArray array];
    for (CLARoom *room in self.tableItems) {
        [self.filteredtableItems addObject:room];
    }
}

- (void)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goButtonClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *topic = self.topicLabel.text;
    
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
    NSLog(@"%@ selected", selectedRoom.name);
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
        self.topicLabel.text = newString;
        
        return NO;
    }
    
    return YES;
}

@end
