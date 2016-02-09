//
//  CLARoom.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLARoom.h"

// Util
#import "Constants.h"

@interface CLARoom ()

@end

@implementation CLARoom

//- (NSMutableArray <CLAMessageViewModel *> *)messages {
//    NSMutableArray <CLAMessageViewModel *> *messages = [[NSMutableArray alloc] init];
//
//    for (CLAMessage *message in self.messages) {
//        CLAMessageViewModel *viewModel = [[CLAMessageViewModel alloc]
//                                          initWithOId:message.key
//                                          SenderId:message.fromUserName
//                                          senderDisplayName:userInitials
//                                          date:date
//                                          text:text];
//
//        messages addObject: <#(nonnull CLAMessageViewModel *)#>
//    }
//
//    return messages;
//}
//
//- (void)setMessages: (NSMutableArray <CLAMessageViewModel *> *)messages {
//}

- (void)getFromDictionary:(NSDictionary *)dictionary {
    self.name = [dictionary objectForKey:@"Name"];
    self.displayName = [dictionary objectForKey:@"DisplayName"];
    self.isPrivate = [[dictionary objectForKey:@"Private"] boolValue];
    self.isDirectRoom = [[dictionary objectForKey:@"IsDirectRoom"] boolValue];
    self.closed = [[dictionary objectForKey:@"Closed"] boolValue];
    
    NSMutableArray *usersArray = [NSMutableArray array];
    NSArray *usersDcitionaryArray = [dictionary objectForKey:@"AllUsersInRoom"];
    
    if (usersDcitionaryArray != nil &&
        usersDcitionaryArray != (id)[NSNull null]) {
        for (NSDictionary *userDictionary in usersDcitionaryArray) {
            CLAUser *user = [CLAUser getFromData:userDictionary];
            [usersArray addObject:user];
        }
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObjectsFromArray:usersArray];
    [realm commitWriteTransaction];
    
    //TODO: add messages and connections to room
    //TODO: add room users
    //self.users = usersArray;
    //self.messages = [NSMutableArray array];
}

- (NSString *)getHandle {
    return self.displayName;
}

@end
