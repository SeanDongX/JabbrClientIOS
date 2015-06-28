//
//  CLACreateRoomViewController.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLACreateRoomViewController.h"
#import "Constants.h"
#import "SlidingViewController.h"
#import "CLANotificationManager.h"
#import "MBProgressHUD.h"
@interface CLACreateRoomViewController ()

@property (weak, nonatomic) IBOutlet UITextField *topicLabel;
@end

@implementation CLACreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    self.topicLabel.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavBar {
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kStatusBarHeight)];
    navBar.barTintColor = [Constants mainThemeColor];
    navBar.translucent = NO;
    navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = NSLocalizedString(@"Create Topic", nil);
    [navBar setItems:@[navItem]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[Constants closeIconImage] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    
    navItem.leftBarButtonItem = closeButton;
    
    [self.view addSubview:navBar];
}

- (void)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goButtonClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *topic = self.topicLabel.text;
    
    CLASignalRMessageClient *messageClient = [CLASignalRMessageClient sharedInstance];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [messageClient createRoom:topic completionBlock:^(NSError *error){
        if (error == nil) {
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            
            [[CLASignalRMessageClient sharedInstance] invokeGetTeam];
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            
            //TODO: define error code
            NSString *errorDescription = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
                                          
            if (errorDescription!= nil && errorDescription.length > 0) {
                [CLANotificationManager showText:errorDescription forViewController:self withType:CLANotificationTypeError];
            }
            else {
                 [CLANotificationManager showText:NSLocalizedString(@"Oh, something went wrong. Let's try it again.", nil) forViewController:self withType:CLANotificationTypeError];
            }
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}


#pragma mark -
#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *regex = @"[^-A-Za-z0-9]";
    NSPredicate *textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([textTest evaluateWithObject:string]){
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:@"-"];
        self.topicLabel.text = newString;
        
        return NO;
    }
    
    return YES;
}

@end
