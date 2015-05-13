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
    UINavigationController *navigaionController = (UINavigationController *)[self.mainViewControllersCache objectForKey:keyIdentifier];
    
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
    //TODO: find how to switch
    //[self switchToHomeView];
    
    [self switchToChatView];
}

- (void)switchToChatView {
    [self setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).slidingViewController = self;
}

- (void)switchToSignInView {
    [self setTopNavigationControllerWithKeyIdentifier:kSignInNavigationController];
    [self resetTopViewAnimated:TRUE];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).slidingViewController = nil;
}

- (void)switchToRoom:(NSString *)room {
    LeftMenuViewController *leftMenu = (LeftMenuViewController *)self.underLeftViewController;
    [leftMenu selectRoom:room closeMenu:YES];
}

- (void)switchToRoomAtNextReload:(NSString *)room {
    
    ChatViewController *chatViewController = (ChatViewController *)[((UINavigationController *)self.topViewController).viewControllers objectAtIndex:0];
    
    if (chatViewController != nil) {
        chatViewController.preselectedTitle = room;
    }
}
@end
