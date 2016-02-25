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

#pragma - Team

- (NSArray <CLATeam*> *)getTeams;
- (CLATeam *)getCurrentOrDefaultTeam;

- (void)addOrUpdateTeamsWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock;

- (void)addOrUpdateTeamWithData:(NSArray *)dictionaryArray
                     completion:(void (^)(void))completionBlock;

#pragma - User

- (CLAUser *)getUserByName: (NSString *)name;

- (void)addOrUpdateUsersWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock;

- (void)joinUser:(NSString *)username toRoom:(NSString *)roomName inTeam:(NSNumber *)teamKey;

#pragma - Room
- (CLARoom *)getRoom:(NSNumber *)roomKey;
- (CLARoom *)getRoomByNameInCurrentOrDefaultTeam:(NSString *)roomName;
- (CLARoom *)getRoom:(NSString *)roomName inTeam:(NSNumber *)teamKey;
- (void)addRoom:(CLARoom *)room inTeam:(NSNumber *)teamKey;
- (void)setRoomUnread:(NSString *)roomName unread:(NSInteger)unread inTeam:(NSNumber *)teamKey;

- (void)addOrUpdateRoomsWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock;


#pragma - Message

- (NSArray <CLAMessage *> *)getRoomMessages: (NSNumber *)roomKey;
- (void)addOrgupdateMessage:(CLAMessage *)message;
- (void)updateMessageKey:(NSString *)oldKey withNewKey:(NSString *)newKey;

- (void)addOrUpdateMessagesWithData:(NSArray *)dictionaryArray
                            forRoom:(NSNumber *)roomKey
                         completion:(void (^)(void))completionBlock;

#pragma - Notification

- (CLANotificationMessage *)getNotificationByKey: (NSNumber *)notificationKey;
- (void)updateNotification: (NSNumber *)notificationKey read:(BOOL)read;

- (void)addOrUpdateNotificationsWithData:(NSArray *)dictionaryArray
                              completion:(void (^)(void))completionBlock;


#pragma - Misc
- (void)deleteData;
- (void)addOrUpdateObjects: (NSArray *)objects
                completion:(void (^)(void))completionBlock;

@end
