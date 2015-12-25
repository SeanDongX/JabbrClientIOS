//
//  SlidingViewController.m
//  Collara
//
//  Created by Sean on 12/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "SlidingViewController.h"

// Util
#import "Constants.h"
#import "UserDataManager.h"

// App
#import "AppDelegate.h"

// View Controller
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"
#import "ChatViewController.h"

#import "CLASignalRMessageClient.h"

@interface SlidingViewController ()

@end

@implementation SlidingViewController

- (void)awakeFromNib {
    self.underLeftViewControllerStoryboardId = kLeftMenuViewController;
    
    self.underRightViewControllerStoryboardId = kRightMenuViewController;
    
    if ([[UserDataManager sharedInstance] isAuthenticated]) {
        self.topViewControllerStoryboardId = kChatNavigationController;
    } else {
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

#pragma mark -
#pragma mark Public Mehtods

- (void)clearControllerCache {
    // TODO: find a way to re init left menu, so that the filter goes away
    [self.mainViewControllersCache removeAllObjects];
}

- (UINavigationController *)setTopNavigationControllerWithKeyIdentifier:
(NSString *)keyIdentifier {
    UINavigationController *navigaionController =
    [self getNavigationControllerWithKeyIdentifier:keyIdentifier];
    
    if (navigaionController == nil) {
        navigaionController = (UINavigationController *)
        [self.storyboard instantiateViewControllerWithIdentifier:keyIdentifier];
        
        navigaionController.view.layer.shadowOpacity = 0.75f;
        navigaionController.view.layer.shadowRadius = 10.0f;
        navigaionController.view.layer.shadowColor = [UIColor blackColor].CGColor;
        
        [self.mainViewControllersCache setObject:navigaionController
                                          forKey:keyIdentifier];
    }
    
    self.topViewController = navigaionController;
    
    return navigaionController;
}

- (UINavigationController *)getNavigationControllerWithKeyIdentifier:
(NSString *)keyIdentifier {
    return (UINavigationController *)
    [self.mainViewControllersCache objectForKey:keyIdentifier];
}

- (void)switchToHomeView {
    [self setTopNavigationControllerWithKeyIdentifier:kHomeNavigationController];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToMainView {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate])
    .slidingViewController = self;
    [self switchToChatView];
    [self switchToHomeView];
}

- (void)switchToChatView {
    [self setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    
    [[CLASignalRMessageClient sharedInstance] connect];
    
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToCreateTeamView {
    [self setTopNavigationControllerWithKeyIdentifier:kCreateTeamViewController];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToSignInView {
    [self
     setTopNavigationControllerWithKeyIdentifier:kSignInNavigationController];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToRoom:(CLARoom *)room {
    LeftMenuViewController *leftMenu = (LeftMenuViewController *)self.underLeftViewController;
    [leftMenu selectRoom:room closeMenu:YES];
}

#pragma mark -
#pragma mark Private Methods

- (void)initNavControllerCache {
    
    self.topViewController.view.layer.shadowOpacity = 0.75f;
    self.topViewController.view.layer.shadowRadius = 10.0f;
    self.topViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.mainViewControllersCache = [NSMutableDictionary dictionary];
    NSString *key = self.topViewControllerStoryboardId;
    [self.mainViewControllersCache setObject:self.topViewController forKey:key];
}

- (void)setFirstView {
    NSString *token = [[UserDataManager sharedInstance] getCachedAuthToken];
    if (token == nil || token.length == 0) {
        [self switchToSignInView];
    } else {
        [self switchToMainView];
    }
}
@end
