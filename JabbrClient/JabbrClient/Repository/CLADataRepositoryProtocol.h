//
//  CLADataRepository.h
//  Collara
//
//  Created by Sean on 02/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLANotificationMessage.h"
#import "CLATeam.h"
#import "CLAUser.h"
#import "CLAMessage.h"

@protocol CLADataRepositoryProtocol <NSObject>


- (NSArray <CLATeam*> *)getTeams;
- (CLATeam *)getCurrentOrDefaultTeam;
- (CLAUser *)getUserByName: (NSString *)name;
- (NSArray <CLAMessage *> *)getRoomMessages: (NSString *)roomName;
- (CLANotificationMessage *)getNotificationByKey: (NSNumber *)notificationKey;

- (void)setRoomUnread:(NSString *)roomName unread:(NSInteger)unread inTeam:(NSNumber *)teamKey;

- (void)addOrgupdateMessage:(CLAMessage *)message;
- (void)updateNotification: (NSNumber *)notificationKey read:(BOOL)read;

- (void)joinUser:(NSString *)username toRoom:(NSString *)roomName inTeam:(NSNumber *)teamKey;

- (void)deleteData;

- (void)addOrUpdateObjects: (NSArray *)objects
                completion:(void (^)(void))completionBlock;

- (void)addOrUpdateTeamsWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock;

- (void)addOrUpdateTeamWithData:(NSArray *)dictionaryArray
                     completion:(void (^)(void))completionBlock;

- (void)addOrUpdateRoomsWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock;

- (void)addOrUpdateUsersWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock;


- (void)addOrUpdateMessagesWithData:(NSArray *)dictionaryArray
                           formRoom:(NSString *)roomName
                         completion:(void (^)(void))completionBlock;

- (void)addOrUpdateNotificationsWithData:(NSArray *)dictionaryArray
                              completion:(void (^)(void))completionBlock;

- (void)addOrUpdateNotifications:(NSArray <CLANotificationMessage*> *)notifications
                      completion:(void (^)(void))completionBlock;

@end
