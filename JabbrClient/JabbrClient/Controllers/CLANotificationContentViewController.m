//
//  CLANotificationContentViewController.m
//  Collara
//
//  Created by Sean on 08/07/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLANotificationContentViewController.h"

// Utils
#import "Constants.h"
#import "DateTools.h"
#import <JSQMessagesViewController/JSQMessages.h>

@interface CLANotificationContentViewController ()

@property(weak, nonatomic) IBOutlet UIView *backgroundView;
@property(weak, nonatomic) IBOutlet UIImageView *userImageView;
@property(weak, nonatomic) IBOutlet UILabel *username;
@property(weak, nonatomic) IBOutlet UILabel *roomName;
@property(weak, nonatomic) IBOutlet UILabel *when;
@property(weak, nonatomic) IBOutlet UILabel *message;

@end

@implementation CLANotificationContentViewController

- (void)viewDidLoad {
    [self setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated {
    self.username.text = [NSString
                          stringWithFormat:@"%@%@", kUserPrefix, self.notification.fromUserName];
    self.roomName.text = [NSString
                          stringWithFormat:@"%@%@", kRoomPrefix, self.notification.roomName];
    
    self.when.text = self.notification.when.timeAgoSinceNow;
    
    self.message.text = self.notification.message;
    
    // fit label
    self.message.numberOfLines = 0;
    [self.message sizeToFit];
    
    JSQMessagesAvatarImage *jSQMessagesAvatarImage =
    [JSQMessagesAvatarImageFactory
     avatarImageWithUserInitials:[[self.notification.fromUserName
                                   substringToIndex:1] capitalizedString]
     backgroundColor:[Constants mainThemeContrastColor]
     textColor:[UIColor whiteColor]
     font:[UIFont systemFontOfSize:18.0f]
     diameter:60.0f];
    
    self.userImageView.image = jSQMessagesAvatarImage.avatarImage;
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
    navItem.title = NSLocalizedString(@"Notification", nil);
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

- (void)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
