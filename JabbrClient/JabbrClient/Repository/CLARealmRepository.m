//
//  CLARealmRepository.m
//  Collara
//
//  Created by Sean on 06/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLARealmRepository.h"
#import "CLANotificationMessage.h"
#import "UserDataManager.h"
#import "CLATeam.h"
#import "CLAUtility.h"

@implementation CLARealmRepository

#pragma - Team

- (NSArray <CLATeam*> *)getTeams {
    return [CLAUtility getArrayFromRLMResult:[CLATeam allObjects]];
}

- (CLATeam *)getCurrentOrDefaultTeam {
    CLATeam *currentTeam = [UserDataManager getTeam];
    
    if (currentTeam != nil && currentTeam.key != nil && currentTeam.key.intValue > 0) {
        RLMResults<CLATeam *>  *teams = [CLATeam objectsWhere:@"key = %d", currentTeam.key.intValue];
        if (teams && teams.firstObject) {
            return teams.firstObject;
        }
    }
    
    CLATeam *team = [CLATeam allObjects].firstObject;
    if (team) {
        [UserDataManager cacheTeam:team];
    }
    
    return team;
}

- (void)addOrUpdateTeamsWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock {
    
    NSArray<CLATeam*> *teams = [CLATeam getFromDataArray:dictionaryArray];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (CLATeam *team in teams) {
            [realm addOrUpdateObjectsFromArray:team.users];
            
            for (CLARoom *room in team.rooms) {
                for (CLAMessage *message in room.messages) {
                    [realm addOrUpdateObject:message.fromUser];
                    [realm addOrUpdateObject:message];
                }
                [realm addOrUpdateObject:room];
            }
            
            [realm addOrUpdateObject:team];
        }
        
        completionBlock();
    }];
}

- (void)addOrUpdateTeamWithData:(NSDictionary *)dictionary
                     completion:(void (^)(void))completionBlock {
    CLATeam *team = [CLATeam getFromData:dictionary];
    if (team) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObjectsFromArray:team.users];
            [realm addOrUpdateObjectsFromArray:team.rooms];
            [realm addOrUpdateObject: team];
            completionBlock();
        }];
    }
}

#pragma - User

- (CLAUser *)getUserByName: (NSString *)name {
    RLMResults<CLAUser *>  *users = [CLAUser objectsWhere:@"name = %@", name];
    return users.firstObject;
}

- (void)joinUser:(NSString *)username toRoom:(NSString *)roomName inTeam:(NSNumber *)teamKey {
    CLAUser *user = [self getUserByName:username];
    CLARoom *room = [self getRoom:roomName inTeam:teamKey];
    
    if (room && user) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [room.users addObject:user];
        [realm addOrUpdateObject:room];
        [realm commitWriteTransaction];
    }
}

- (void)addOrUpdateUsersWithData: (NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock {
    [self addOrUpdateObjects:[CLAUser getFromDataArray:dictionaryArray]
                  completion:completionBlock];
}

#pragma - Room

- (CLARoom *)getRoom:(NSNumber *)roomKey {
    return [CLARoom objectsWhere:@"key = %d", roomKey.intValue].firstObject;
}

- (CLARoom *)getRoomByNameInCurrentOrDefaultTeam:(NSString *)roomName {
    CLATeam *team = [self getCurrentOrDefaultTeam];
    if (team && team.rooms) {
        return [team.rooms objectsWhere: @"name = %@", roomName].firstObject;
    }
    
    return nil;
}

- (CLARoom *)getRoom:(NSString *)name inTeam:(NSNumber *)teamKey {
    CLATeam *team = [CLATeam objectsWhere:@"key = %d", teamKey.intValue].firstObject;
    if (!team) {
        return nil;
    }
    
    return [team.rooms objectsWhere:@"name = %@", name].firstObject;
}

- (void)addRoom:(CLARoom *)room inTeam:(NSNumber *)teamKey {
    CLATeam *team = [CLATeam objectsWhere:@"key = %d", teamKey.intValue].firstObject;
    if (team) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:room];
        [team.rooms addObject:room];
        [realm addOrUpdateObject:team];
        [realm commitWriteTransaction];
    }
}

- (void)setRoomUnread:(NSString *)roomName unread:(NSInteger)unread inTeam:(NSNumber *)teamKey {
    CLARoom *room = [self getRoom:roomName inTeam:teamKey];
    if (room) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        room.unread = unread;
        [realm commitWriteTransaction];
    }
}


- (void)addOrUpdateRoomsWithData:(NSArray *)dictionaryArray
                      completion:(void (^)(void))completionBlock {
    NSArray<CLARoom*> *rooms = [CLARoom getFromDataArray:dictionaryArray];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (CLARoom *room in rooms) {
            [realm addOrUpdateObjectsFromArray:room.users];
            [realm addOrUpdateObjectsFromArray:room.owners];
            [realm addOrUpdateObjectsFromArray:room.messages];
            [realm addOrUpdateObject:room];
        }
        
        completionBlock();
    }];
}

#pragma - Message

- (NSArray <CLAMessage *> *)getRoomMessages: (NSNumber *)roomKey {
    RLMResults<CLAMessage *>  *messages = [[CLAMessage objectsWhere:@"roomKey = %d", roomKey.intValue] sortedResultsUsingProperty:@"when" ascending:NO];
    return [CLARealmRepository RLMResultsToNSArray:messages];
}


- (void)addOrgupdateMessage:(CLAMessage *)message {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:message];
    [realm commitWriteTransaction];
}

- (void)updateMessageKey:(NSString *)oldKey withNewKey:(NSString *)newKey {
    CLAMessage *oldMessage = [CLAMessage objectsWhere: @"key = %@", oldKey].firstObject;
    
    if (oldMessage) {
        CLAMessage *newMessage = [CLAMessage copyFromMessage:oldMessage];
        newMessage.key = newKey;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:oldMessage];
        [realm addOrUpdateObject:newMessage];
        [realm commitWriteTransaction];
    }
}

- (void)addOrUpdateMessagesWithData:(NSArray *)dictionaryArray
                            forRoom:(NSNumber *)roomKey
                         completion:(void (^)(void))completionBlock {
    [self addOrUpdateObjects:[CLAMessage getFromDataArray:dictionaryArray forRoom:roomKey]
                  completion:completionBlock];
}

#pragma - Notification

- (CLANotificationMessage *)getNotificationByKey: (NSNumber *)notificationKey {
    RLMResults<CLANotificationMessage *>  *notification = [CLANotificationMessage objectsWhere:@"notificationKey = %@", notificationKey];
    return notification.firstObject;
}

- (void)updateNotification: (NSNumber *)notificationKey read:(BOOL)read {
    CLANotificationMessage *notification = [self getNotificationByKey:notificationKey];
    if (notification) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            notification.read = read;
        }];
    }
}

- (void)addOrUpdateNotificationsWithData: (NSArray *)dictionaryArray
                              completion:(void (^)(void))completionBlock {
    [self addOrUpdateObjects:[CLANotificationMessage getFromDataArray:dictionaryArray]
                  completion:completionBlock];
}

#pragma - Misc
- (void)deleteData {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)addOrUpdateObjects: (NSArray *)objects
                completion:(void (^)(void))completionBlock {
    if (objects.count > 0) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObjectsFromArray:objects];
            completionBlock();
        }];
    }
    
    completionBlock();
}

+ (NSArray *) RLMResultsToNSArray:(RLMResults *)results {
    NSMutableArray *array = [NSMutableArray array];
    for (RLMObject *object in results) {
        [array addObject:object];
    }
    return array;
}

@end
