// LeftMenuViewController.m
// TransitionFun
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LeftMenuViewController.h"

//Util
#import "DemoData.h"
#import "ChatThread+Category.h"
#import "Constants.h"

//Menu
#import "UIViewController+ECSlidingViewController.h"
#import "SlidingViewController.h"

//Control
#import "CLARoundFrameButton.h"

//View Controller
#import "ChatViewController.h"
#import "CLACreateRoomViewController.h"

@interface LeftMenuViewController ()

@property (nonatomic, strong) NSArray *chatThreads;
@property (weak, nonatomic) IBOutlet UIImageView *settingsIcon;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenu];
    [self setupSettingsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateChatThreads:self.chatThreads];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)setupMenu {
    
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    
    self.slidingViewController.anchorLeftPeekAmount  = 50.0;
    self.slidingViewController.anchorRightPeekAmount = 50.0;
}

- (void)setupSettingsView {
    [self.settingsIcon setImage: [Constants settingsImage]];
    self.settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

#pragma mark - Properties

- (NSMutableDictionary *)controllers {
    SlidingViewController *slidingViewConroller = (SlidingViewController *)self.slidingViewController;
    if (slidingViewConroller != nil) {
        return slidingViewConroller.mainViewControllersCache;
    }
    
    NSLog(@"Error: no main view controllers found in sliding view controller");
    return nil;
}

#pragma mark -
#pragma mark - Public Methods

- (void)updateChatThreads:(NSArray *)chatThreads {
    
    //Find current selected
    NSInteger currentSelected = -1;
    NSString *selectedChatTitle = nil;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        currentSelected = selectedIndexPath.row;
    }
    
    if (self.chatThreads != nil && self.chatThreads.count > currentSelected) {
        ChatThread *selectedChatThrad = self.chatThreads[currentSelected];
        selectedChatTitle = selectedChatThrad.title;
    }
    
    //Update threads array and table view
    self.chatThreads = chatThreads;
    [self.tableView reloadData];
    
    //select last selected, if any
    [self selectThread:selectedChatTitle closeMenu:NO];
}

- (void)selectThread: (NSString *)title closeMenu:(BOOL)close {
    //TODO: support section
    if (title == nil)
    {
        return;
    }
    
    for (int key=0 ; key< self.chatThreads.count; key++) {
        ChatThread *thread = [self.chatThreads objectAtIndex:key];
        
        if ([thread.title isEqualToString: title]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:key inSection:0];
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            
            if (close != NO) {
                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            }
            
            return;
        }
    }
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.chatThreads.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ChatThread *chatThread = self.chatThreads[indexPath.row];
    cell.textLabel.text = [chatThread getDisplayTitle];

    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [Constants mainThemeColor];
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

#pragma mark - Table Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = tableView.frame;
    
    UIView *hightlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 5, 30)];
    [hightlightView setBackgroundColor:[Constants mainThemeColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    title.text = [NSString stringWithFormat: @"Topics (%lu)", (unsigned long)self.chatThreads.count];
    title.textColor = [UIColor whiteColor];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 10, 30, 30)];
    
    [addButton addTarget:self action:@selector(showCreateTopicView) forControlEvents:UIControlEventTouchUpInside];

    [addButton setImage:[Constants addIconImage] forState:UIControlStateNormal];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [headerView setBackgroundColor: [Constants mainThemeContrastFocusColor]];
    
    [headerView addSubview:hightlightView];
    [headerView addSubview:title];
    [headerView addSubview:addButton];

    return headerView;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);

    UINavigationController *navController = nil;
    
    if (indexPath.row == self.chatThreads.count) {
        
        navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kProfileNavigationController];

        [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    else {
        
        navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
        
        ChatViewController *chatViewController = [navController.viewControllers objectAtIndex:0];
        
        if (chatViewController != nil) {
            [chatViewController switchToChatThread:self.chatThreads[indexPath.row]];
        }
    }
        
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}


#pragma mark -
#pragma mark - Event Handlers

- (void)showCreateTopicView {
        
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kMainStoryBoard bundle: nil];
    
    CLACreateRoomViewController *createRoomViewController = [storyBoard instantiateViewControllerWithIdentifier:kCreateRoomViewController];
    createRoomViewController.slidingMenuViewController = (SlidingViewController *)self.slidingViewController;
    [self presentViewController:createRoomViewController animated:YES completion:nil];
}

- (IBAction)settingsButtonClicked:(id)sender {
    UINavigationController *navController = [((SlidingViewController *)self.slidingViewController) setTopNavigationControllerWithKeyIdentifier:kProfileNavigationController];
        
    [navController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

@end
