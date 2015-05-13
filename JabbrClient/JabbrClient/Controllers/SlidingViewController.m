//
//  SlidingViewController.m
//  Collara
//
//  Created by Sean on 12/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "SlidingViewController.h"

//Util
#import "Constants.h"
#import "AuthManager.h"

//App
#import "AppDelegate.h"

//View Controller
#import "LeftMenuViewController.h"
#import "ChatViewController.h"

@interface SlidingViewController ()

@end

@implementation SlidingViewController

- (void)awakeFromNib {
    self.underLeftViewControllerStoryboardId = kLeftMenuViewController;
    self.underRightViewControllerStoryboardId = kRightMenuViewController;
    
    if ([[AuthManager sharedInstance] isAuthenticated]) {
        self.topViewControllerStoryboardId = kChatNavigationController;
    }
    else {
        self.topViewControllerStoryboardId = kSignInNavigationController;
    }
    
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavControllerCache];
    [self setFirstView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initNavControllerCache {
    
    self.topViewController.view.layer.shadowOpacity = 0.75f;
    self.topViewController.view.layer.shadowRadius = 10.0f;
    self.topViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.mainViewControllersCache = [NSMutableDictionary dictionary];
    NSString *key = self.topViewControllerStoryboardId;
    [self.mainViewControllersCache setObject:self.topViewController forKey:key];
}

- (UINavigationController *)setTopNavigationControllerWithKeyIdentifier:(NSString *)keyIdentifier {
    UINavigationController *navigaionController = [self getNavigationControllerWithKeyIdentifier:keyIdentifier];
    
    if (navigaionController == nil) {
        navigaionController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:keyIdentifier];
        
        navigaionController.view.layer.shadowOpacity = 0.75f;
        navigaionController.view.layer.shadowRadius = 10.0f;
        navigaionController.view.layer.shadowColor = [UIColor blackColor].CGColor;
        
        [self.mainViewControllersCache setObject:navigaionController forKey:keyIdentifier];
    }
    
    self.topViewController = navigaionController;
    
    return navigaionController;
}

- (UINavigationController *)getNavigationControllerWithKeyIdentifier:(NSString *)keyIdentifier {
    return (UINavigationController *)[self.mainViewControllersCache objectForKey:keyIdentifier];
}

- (void)setFirstView {
    NSString *token = [[AuthManager sharedInstance] getCachedAuthToken];
    if (token == nil || token.length == 0) {
        [self switchToSignInView];
    }
    else {
        [self switchToMainView];
    }
}


- (void)switchToHomeView {
    [self setTopNavigationControllerWithKeyIdentifier:kHomeNavigationController];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).slidingViewController = self;
}

- (void)switchToMainView {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).slidingViewController = self;
    //TODO: find how to switch
    [self switchToChatView];
    [self switchToHomeView];
}

- (void)switchToChatView {
    [self setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToSignInView {
    [self setTopNavigationControllerWithKeyIdentifier:kSignInNavigationController];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToRoom:(NSString *)room {
    LeftMenuViewController *leftMenu = (LeftMenuViewController *)self.underLeftViewController;
    [leftMenu selectRoom:room closeMenu:YES];
}

- (void)switchToRoomAtNextReload:(NSString *)room {
    UINavigationController *navController = [self getNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    if (navController != nil) {
        ChatViewController *chatViewController = (ChatViewController *)[navController.viewControllers objectAtIndex:0];
        
        if (chatViewController != nil) {
            chatViewController.preselectedTitle = room;
        }
    }
}
@end
