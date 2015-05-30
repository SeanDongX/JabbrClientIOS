//
//  CLATeamViewModel.m
//  Collara
//
//  Created by Sean on 01/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLATeamViewModel.h"

@implementation CLATeamViewModel

+ (CLATeamViewModel *)getFromData: (NSDictionary *)teamDictionary {
    
    CLATeam *team = [[CLATeam alloc] init];
    team.name = [teamDictionary objectForKey:@"Name"];
    team.key = [teamDictionary objectForKey:@"Key"];
    
    NSMutableArray<CLARoom> *roomArray = [NSMutableArray array];
    NSArray *roomArrayFromDictionary = [teamDictionary objectForKey:@"Rooms"];
    if (roomArrayFromDictionary != nil && roomArrayFromDictionary.count > 0){
        
        for (id room in roomArrayFromDictionary) {
            NSDictionary *roomDictionary = room;
            CLARoom *claRoom = [[CLARoom alloc] init];
            claRoom.name = [roomDictionary objectForKey:@"Name"];
            
            //NSMutableArray *usersArray = [NSMutableArray array];
            //TODO: add users and owners to room
            [roomArray addObject:claRoom];
        }
    }
    
    NSMutableArray<CLAUser> *userArray = [NSMutableArray array];
    NSArray *userArrayFromDictionary = [teamDictionary objectForKey:@"Users"];
    if (userArrayFromDictionary != nil && userArrayFromDictionary.count > 0){
        
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
