//
//  SlidingViewController.h
//  JabbrClient
//
//  Created by Sean on 05/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "ECSlidingViewController.h"

@interface SlidingViewController : ECSlidingViewController
@property  NSMutableDictionary *mainViewControllersCache;

- (UINavigationController *)setTopNavigationControllerWithKeyIdentifier:(NSString *)keyIdentifier;
- (void)switchToMainView;
- (void)switchToSignInView;
    
@end
