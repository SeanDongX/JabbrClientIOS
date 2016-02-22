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

+ (NSString *)primaryKey {
    return @"key";
}

+ (NSArray <CLARoom *> *)getFromDataArray:(NSArray *)dictionaryArray {
    NSMutableArray <CLARoom *> *rooms = [NSMutableArray array];
    if (dictionaryArray && dictionaryArray != [NSNull null] && dictionaryArray.count > 0) {
        for (NSDictionary *dictionary in dictionaryArray) {
            CLARoom *room = [CLARoom getFromData:dictionary];
            if (room) {
                [rooms addObject:room];
            }
        }
    }
    return rooms;
}

+ (CLARoom *)getFromData:(NSDictionary *)dictionary {
    CLARoom *room = [[CLARoom alloc] init];
    room.key = [dictionary objectForKey:@"Key"];
    room.name = [dictionary objectForKey:@"Name"];
    room.displayName = [dictionary objectForKey:@"DisplayName"];
    room.isPrivate = [[dictionary objectForKey:@"Private"] boolValue];
    room.isDirectRoom = [[dictionary objectForKey:@"IsDirectRoom"] boolValue];
    room.closed = [[dictionary objectForKey:@"Closed"] boolValue];
    
    NSArray *usersDcitionaryArray = [dictionary objectForKey:@"AllUsersInRoom"];
    [room.users addObjects: [CLAUser getFromDataArray:usersDcitionaryArray]];
    
    NSArray *recentMessageArray = [dictionary objectForKey:@"RecentMessages"];
    [room.messages addObjects:[CLAMessage getFromDataArray:recentMessageArray forRoom:room.key]];
    
    return room;
}

- (NSString *)getHandle {
    return self.displayName;
}

@end
