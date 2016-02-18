//
//  SlidingViewController.h
//  Collara
//
//  Created by Sean on 12/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "CLARoom.h"

@interface SlidingViewController : ECSlidingViewController
@property NSMutableDictionary *mainViewControllersCache;

- (UINavigationController *)getNavigationControllerWithKeyIdentifier:
(NSString *)keyIdentifier;
- (UINavigationController *)setTopNavigationControllerWithKeyIdentifier:
(NSString *)keyIdentifier;
- (void)clearControllerCache;
- (void)switchToMainView;
- (void)switchToSignInView;
- (void)switchToCreateTeamView:(NSString *)invitationId sourceViewIdentifier:(NSString*)sourceViewIdentifier;
- (void)switchToRoom:(CLARoom *)room;

@end
