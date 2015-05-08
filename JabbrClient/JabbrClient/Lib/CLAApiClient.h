//
//  CLAApiClient.h
//  Collara
//
//  Created by Sean on 07/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAUserRegistrationViewModel.h"

@protocol CLAApiClient;

@protocol CLAApiClient <NSObject>

- (void)createAccount:(CLAUserRegistrationViewModel *)userRegistrationModel completionHandler:(void (^)(NSString *errorMessage))completion;
- (void)createTeam:(NSString *)name completionHandler:(void(^)(NSString *errorMessage))completion;
- (void)joinTeam:(NSString *)name completionHandler:(void(^)(NSString *errorMessage))completion;
- (void)sendInviteFor:(NSString*)team to:(NSString *)email completion: (void(^)(NSString *token, NSString *errorMessage))completion;
@end
