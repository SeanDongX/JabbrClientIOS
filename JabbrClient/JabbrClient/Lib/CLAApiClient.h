//
//  CLAApiClient.h
//  Collara
//
//  Created by Sean on 07/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CLAUserRegistrationViewModel.h"
#import "CLANotificationMessage.h"
#import "CLATeam.h"

@protocol CLAApiClient;

@protocol CLAApiClient <NSObject>

- (void)createAccount:(CLAUserRegistrationViewModel *)userRegistrationModel
    completionHandler:(void (^)(NSString *errorMessage))completion;

- (void)signInWith:(NSString *)username
          password:(NSString *)password
 completionHandler:(void (^)(NSString *errorMessage))completion;

- (void)getTeams:(void (^)(NSArray<CLATeam *> *teams, NSString *errorMessage))completion;

- (void)createTeam:(NSString *)name
 completionHandler:(void (^)(CLATeam *team, NSString *errorMessage))completion;

- (void)joinTeam:(NSString *)invitationCode
completionHandler:(void (^)(CLATeam *team, NSString *errorMessage))completion;

- (void)getInviteCodeForTeam:(NSNumber *)team
                  completion:(void (^)(NSString *invitationCode,
                                       NSString *errorMessage))completion;

- (void)sendInviteFor:(NSString *)team
                   to:(NSString *)email
           completion: (void (^)(NSString *token, NSString *errorMessage))completion;

- (void)getNotificationsFor:(NSString *)team
                 completion:(void (^)(NSArray *result,
                                      NSString *errorMessage))completion;

- (void)setRead:(CLANotificationMessage *)notification
     completion:(void (^)(NSArray *result, NSString *errorMessage))completion;

- (void)setBadge:(NSNumber *)count
         forTeam:(NSNumber *)teamKey;

- (void)getNotificationStateFor:(NSString *)roomName
                           team:(NSString *)team
              completionHandler:(void (^)(NSString *errorMessage))completion;

- (void)setNotificationStateFor:(NSString *)roomName
                           team:(NSString *)team
                    snoozeUntil:(NSDate *)date
              completionHandler:(void (^)(NSString *errorMessage))completion;


- (void)uploadImage:(UIImage *)image
          imageName:(NSString *)imageName
           fromRoom:(NSString *)roomName
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure;

@end
