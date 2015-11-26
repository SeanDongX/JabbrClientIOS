//
//  CLATeamViewModel.m
//  Collara
//
//  Created by Sean on 01/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLATeamViewModel.h"
#import "CLAUtility.h"

@implementation CLATeamViewModel

- (NSArray<CLARoom> *)getJoinedRooms {
    NSMutableArray *roomArray = [NSMutableArray array];
    for (CLARoom *room in [self.rooms allValues]) {
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

- (NSArray<CLARoom> *)getNotJoinedRooms {
    NSMutableArray *roomArray = [NSMutableArray array];
    for (CLARoom *room in [self.rooms allValues]) {
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

- (void)joinUser:(CLAUser *)newUser toRoom:(NSString *)roomName {
    if (newUser == nil || newUser.name == nil) {
        return;
    }
    
    for (CLARoom *room in [self.rooms allValues]) {
        if (room.name != nil && [room.name isEqualToString:roomName]) {
            BOOL userFound = FALSE;
            
            for (CLAUser *user in room.users) {
                if ([CLAUtility isString:newUser.name
                  caseInsensitiveEqualTo:user.name]) {
                    userFound = TRUE;
                    // break on first user instance found
                    break;
                }
            }
            
            if (userFound == FALSE) {
                if (room.users == nil) {
                    room.users = @[];
                }
                
                NSMutableArray<CLAUser> *copyUsers = [room.users mutableCopy];
                [copyUsers addObject:newUser];
                room.users = copyUsers;
            }
            
            // return on first room instance found
            return;
        }
    }
}

+ (CLATeamViewModel *)getFromData:(NSDictionary *)teamDictionary {
    
    CLATeam *team = [[CLATeam alloc] init];
    team.name = [teamDictionary objectForKey:@"Name"];
    team.key = [teamDictionary objectForKey:@"Key"];
    
    NSMutableDictionary *roomArray = [NSMutableDictionary dictionary];
    NSArray *roomArrayFromDictionary = [teamDictionary objectForKey:@"Rooms"];
    if (roomArrayFromDictionary != nil && roomArrayFromDictionary.count > 0) {
        
        for (id room in roomArrayFromDictionary) {
            NSDictionary *roomDictionary = room;
            CLARoom *claRoom = [[CLARoom alloc] init];
            [claRoom getFromDictionary:roomDictionary];
            [roomArray setObject:claRoom forKey:claRoom.name];
        }
    }
    
    NSMutableArray<CLAUser> *userArray = [NSMutableArray array];
    NSArray *userArrayFromDictionary = [teamDictionary objectForKey:@"Users"];
    if (userArrayFromDictionary != nil && userArrayFromDictionary.count > 0) {
        
        for (id userDictionary in userArrayFromDictionary) {
            [userArray addObject:[CLAUser getFromData:userDictionary]];
        }
    }
    
    CLATeamViewModel *teamViewModel = [[CLATeamViewModel alloc] init];
    teamViewModel.team = team;
    teamViewModel.rooms = roomArray;
    teamViewModel.users = userArray;
    
    return teamViewModel;
}
@end
