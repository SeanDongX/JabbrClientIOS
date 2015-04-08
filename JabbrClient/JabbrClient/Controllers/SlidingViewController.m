//
//  SlidingViewController.m
//  JabbrClient
//
//  Created by Sean on 05/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "SlidingViewController.h"
#import "AuthManager.h"
#import "Constants.h"

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
    [self.mainViewControllersCache setObject:self.topViewController forKeyedSubscript:key];
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

- (void)switchToMainView {
    
    [self setTopNavigationControllerWithKeyIdentifier:kChatNavigationController];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    [self resetTopViewAnimated:TRUE];
}

- (void)switchToSignInView {
    [self setTopNavigationControllerWithKeyIdentifier:kSignInNavigationController];
    [self resetTopViewAnimated:TRUE];
}
@end
