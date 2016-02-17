//
//  CLAInvitationHandler.m
//  Collara
//
//  Created by Sean on 17/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLAInvitationHandler.h"
#import "UserDataManager.h"
#import "SlidingViewController.h"
#import "Constants.h"

@implementation CLAInvitationHandler

- (void)processInvitation:(NSString *)invitationId {
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    SlidingViewController *root = (SlidingViewController *)[window rootViewController];
    [UserDataManager cacheObject: invitationId forKey: kinvitationId];
    if ([UserDataManager isAuthenticated] == NO) {
        [root switchToSignInView];
    } else {
        [root switchToCreateTeamView:invitationId];
    }
}

@end
