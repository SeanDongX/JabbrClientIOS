//
//  CLATeam.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLATeam.h"

@implementation CLATeam

+ (CLATeam *)getFromData:(NSDictionary *)teamDictionary {
    CLATeam *team = [[CLATeam alloc] init];
    team.name = [teamDictionary objectForKey:@"name"];
    team.key = [teamDictionary objectForKey:@"key"];
    return team;
}

+ (NSArray <CLATeam *> *)getTeamsFromData:(NSArray *)teamDictionaryArray {
    NSMutableArray *teamArray = [NSMutableArray array];
    for (NSDictionary *dictionary in teamDictionaryArray) {
        CLATeam *team = [CLATeam getFromData:dictionary];
        [teamArray addObject:team];
    };
    
    return teamArray;
}

@end
