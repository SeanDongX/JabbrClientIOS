//
//  CLARoom.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLARoom.h"

//Util
#import "Constants.h"

@implementation CLARoom


- (void)getFromDictionary:(NSDictionary*)dictionary {
    self.name = [dictionary objectForKey:@"Name"];
    self.displayName = [dictionary objectForKey:@"DisplayName"];
    self.isPrivate = [[dictionary objectForKey:@"Private"] boolValue];
    self.isDirectRoom = [[dictionary objectForKey:@"IsDirectRoom"] boolValue];
    self.closed = [[dictionary objectForKey:@"Closed"] boolValue];
    
    NSMutableArray *usersArray = [NSMutableArray array];
    NSArray *usersDcitionaryArray = [dictionary objectForKey:@"AllUsersInRoom"];
    
    if (usersDcitionaryArray != nil && usersDcitionaryArray != (id)[NSNull null]) {
        for (NSDictionary *userDictionary in usersDcitionaryArray) {
            CLAUser *user = [CLAUser getFromData:userDictionary];
            [usersArray addObject:user];
        }
    }
    
    self.users = usersArray;
    self.messages = [NSMutableArray array];
}


- (NSString *)getHandle {
    return self.isDirectRoom ? [CLARoom getDirectRoomHandle:self.displayName] : [CLARoom getRoomHandle:self.displayName];
}

+ (NSString *)getRoomHandle: (NSString *)roomName {
    return [NSString stringWithFormat:@"%@%@", kRoomPrefix, roomName];
}

+ (NSString *)getDirectRoomHandle: (NSString *)roomName {
    return [NSString stringWithFormat:@"%@%@", kUserPrefix, roomName];
}
@end
