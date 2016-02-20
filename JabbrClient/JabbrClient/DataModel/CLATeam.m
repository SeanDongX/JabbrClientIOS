//
//  CLATeam.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLATeam.h"
#import "CLARoom.h"
#import "CLAUtility.h"

@implementation CLATeam

+ (NSString *)primaryKey {
    return @"key";
}

+ (NSArray <CLATeam *> *)getFromDataArray:(NSArray *)dictionaryArray {
    NSMutableArray <CLATeam *> *teams = [NSMutableArray array];
    if (dictionaryArray && dictionaryArray != [NSNull null] && dictionaryArray.count > 0) {
        for (NSDictionary *dictionary in dictionaryArray) {
            CLATeam *team = [CLATeam getFromData:dictionary];
            if (team) {
                [teams addObject:team];
            }
        }
    }
    return teams;
}

+ (CLATeam *)getFromData:(NSDictionary *)teamDictionary {
    
    CLATeam *team = [[CLATeam alloc] init];
    team.name = [teamDictionary objectForKey:@"Name"];
    team.key = [teamDictionary objectForKey:@"Key"];
    
    NSArray *roomArrayFromDictionary = [teamDictionary objectForKey:@"Rooms"];
    NSArray *roomArray = [CLARoom getFromDataArray:roomArrayFromDictionary];
    
    NSArray *userArrayFromDictionary = [teamDictionary objectForKey:@"Users"];
    NSArray<CLAUser *> *userArray = [CLAUser getFromDataArray:userArrayFromDictionary];
    
    [team.rooms addObjects:roomArray];
    [team.users addObjects:userArray];
    
    return team;
}

- (NSArray<CLARoom *> *)getJoinedRooms {
    NSMutableArray *roomArray = [NSMutableArray array];
    for (CLARoom *room in self.rooms) {
        if (room.closed == false && room.users != nil && room.users.count > 0) {
            for (CLAUser *user in room.users) {
                if ([user isCurrentUser] != NO) {
                    [roomArray addObject:room];
                    break;
                }
            }
        }
    }
    
    return roomArray;
}

- (NSArray<CLARoom *> *)getNotJoinedRooms {
    NSMutableArray *roomArray = [NSMutableArray array];
    for (CLARoom *room in self.rooms) {
        if (room.closed == true || room.users == nil || room.users.count == 0 || room.isDirectRoom != NO) {
            [roomArray addObject:room];
        }
        else if (room.users != nil && room.users.count > 0) {
            BOOL userInRoom = NO;
            for (CLAUser *user in room.users) {
                if ([user isCurrentUser] != NO) {
                    userInRoom = YES;
                    break;
                }
            }
            
            if (userInRoom == NO) {
                [roomArray addObject:room];
            }
        }
    }
    
    return roomArray;
}

- (CLAUser *)findUser:(NSString *)username {
    for (CLAUser *user in self.users) {
        if ([CLAUtility isString:username caseInsensitiveEqualTo:user.name]) {
            return user;
        }
    }
    
    return nil;
}

@end
