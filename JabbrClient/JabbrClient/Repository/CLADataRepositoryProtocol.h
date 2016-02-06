//
//  CLADataRepository.h
//  Collara
//
//  Created by Sean on 02/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLATeamViewModel.h"
#import "CLANotificationMessage.h"

@protocol CLADataRepositoryProtocol <NSObject>

- (CLATeamViewModel *)get:(NSString *)name;
- (CLATeamViewModel *)getCurrentOrDefaultTeam;
- (NSArray<CLATeamViewModel *> *)getTeams;
- (void)addOrUpdateTeam:(CLATeamViewModel *)team;
- (void)deleteData;

- (CLAUser *)getUserByName: (NSString *)name;

- (CLANotificationMessage *)updateNotification: (NSNumber *)notificationKey read:(BOOL)read;
- (CLANotificationMessage *)getNotificationByKey: (NSNumber *)notificationKey;
- (void)addOrUpdateNotificationsWithData: (NSArray *)dictionaryArray
                              completion:(void (^)(void))completionBlock;

- (void)addOrUpdateNotifications: (NSArray <CLANotificationMessage*> *)notifications
                      completion:(void (^)(void))completionBlock;


@end
