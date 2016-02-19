//
//  CLATeam.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "CLAUser.h"
#import "CLARoom.h"

@interface CLATeam : RLMObject

@property(nonatomic, strong) NSNumber<RLMInt> *key;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong)RLMArray<CLAUser *><CLAUser> *users;
@property(nonatomic, strong)RLMArray<CLARoom *><CLARoom> *rooms;

+ (CLATeam *)getFromData:(NSDictionary *)teamDictionary;
+ (NSArray <CLATeam *> *)getFromDataArray:(NSArray *)dictionaryArray;

- (NSArray<CLARoom *> *)getJoinedRooms;
- (NSArray<CLARoom *> *)getNotJoinedRooms;
- (CLAUser *)findUser:(NSString *)username;

@end
