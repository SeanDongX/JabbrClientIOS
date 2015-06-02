//
//  DataRepository.m
//  Collara
//
//  Created by Sean on 02/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAInMemoryDataRepository.h"
@interface CLAInMemoryDataRepository()

@property (nonatomic, strong)NSMutableArray<CLATeamViewModel> *teamViewModelArray;

@end

@implementation CLAInMemoryDataRepository

- (id) init {
    self = [super init];
    self.teamViewModelArray = [NSMutableArray array];
    return self;
}

-(CLATeamViewModel *)get:(NSString*)name {
    for (CLATeamViewModel *team in self.teamViewModelArray) {
        if (team.team.name == name) {
            return team;
        }
    }
    
    return nil;
}

-(CLATeamViewModel *)getDefaultTeam {
    return self.teamViewModelArray.count > 0 ? self.teamViewModelArray[0] : nil;
}

-(NSArray<CLATeamViewModel> *)getTeams {
    return self.teamViewModelArray;
}

-(void)addTeam:(CLATeamViewModel *)team {
    [self.teamViewModelArray addObject:team];
}

@end
