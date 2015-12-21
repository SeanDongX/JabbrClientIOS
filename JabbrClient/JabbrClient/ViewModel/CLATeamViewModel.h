//
//  CLATeamViewModel.h
//  Collara
//
//  Created by Sean on 01/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

// Data Model
#import "CLATeam.h"
#import "CLAUser.h"
#import "CLARoom.h"

@interface CLATeamViewModel : NSObject

@property(nonatomic, strong) CLATeam *team;
@property(nonatomic, strong) NSMutableDictionary *rooms;
@property(nonatomic, strong) NSArray<CLAUser *> *users;

- (NSArray<CLARoom *> *)getJoinedRooms;
- (NSArray<CLARoom *> *)getNotJoinedRooms;
- (CLAUser *)findUser:(NSString *)username;
- (void)joinUser:(CLAUser *)newUser toRoom:(NSString *)roomName;

+ (CLATeamViewModel *)getFromData:(NSDictionary *)data;

@end
