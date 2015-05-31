//
//  SlidingViewController.h
//  Collara
//
//  Created by Sean on 12/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "ECSlidingViewController.h"

@interface SlidingViewController : ECSlidingViewController
@property  NSMutableDictionary *mainViewControllersCache;

- (UINavigationController *)getNavigationControllerWithKeyIdentifier:(NSString *)keyIdentifier;
- (UINavigationController *)setTopNavigationControllerWithKeyIdentifier:(NSString *)keyIdentifier;
- (void)switchToMainView;
- (void)switchToSignInView;
- (void)switchToCreateTeamView;
- (void)switchToCreateTopicView;
- (void)switchToRoom: (NSString *)room;
- (void)switchToRoomAtNextReload: (NSString *)room;

@end
