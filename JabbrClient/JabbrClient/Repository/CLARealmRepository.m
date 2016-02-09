//
//  CLARealmRepository.m
//  Collara
//
//  Created by Sean on 06/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLARealmRepository.h"
#import "CLANotificationMessage.h"

@implementation CLARealmRepository

- (CLATeamViewModel *)get:(NSString *)name {
    return nil;
}

- (CLATeamViewModel *)getCurrentOrDefaultTeam {
    return nil;
}

- (NSArray<CLATeamViewModel *> *)getTeams {
    return nil;
}

- (void)addOrUpdateTeam:(CLATeamViewModel *)team {
}

- (void)deleteData {
}

- (CLAUser *)getUserByName: (NSString *)name {
    RLMResults<CLAUser *>  *users = [CLAUser objectsWhere:@"name = %@", name];
    return users.firstObject;
}

- (NSArray <CLAMessage *> *)getRoomMessages: (NSString *)roomName {
    RLMResults<CLAMessage *>  *messages = [CLAMessage objectsWhere:@"roomName = %@", roomName];
    return [CLARealmRepository RLMResultsToNSArray:messages];
}

- (void)addOrgupdateMessage:(CLAMessage *)message {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:message];
    [realm commitWriteTransaction];
}

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
    NSMutableArray <CLANotificationMessage *> *notifications = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaryArray) {
        CLANotificationMessage *notification = [CLANotificationMessage getFromData:dictionary];
        if (notification) {
            [notifications addObject:notification];
        }
    }
    
    [self addOrUpdateNotifications:notifications completion:completionBlock];
}

- (void)addOrUpdateNotifications: (NSArray <CLANotificationMessage*> *)notifications
                      completion:(void (^)(void))completionBlock {
    if (notifications.count > 0) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObjectsFromArray:notifications];
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
