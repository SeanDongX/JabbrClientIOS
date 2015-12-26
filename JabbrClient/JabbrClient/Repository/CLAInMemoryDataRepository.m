//
//  DataRepository.m
//  Collara
//
//  Created by Sean on 02/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAInMemoryDataRepository.h"
#import "UserDataManager.h"
@interface CLAInMemoryDataRepository ()

@property(nonatomic, strong)
NSMutableArray<CLATeamViewModel *> *teamViewModelArray;

@end

@implementation CLAInMemoryDataRepository

- (id)init {
    self = [super init];
    self.teamViewModelArray = [NSMutableArray array];
    return self;
}

- (CLATeamViewModel *)get:(NSString *)name {
    for (CLATeamViewModel *team in self.teamViewModelArray) {
        if (team.team.name == name) {
            return team;
        }
    }
    
    return nil;
}

- (CLATeamViewModel *)getCurrentOrDefaultTeam {
    if (self.teamViewModelArray != nil && self.teamViewModelArray.count > 0 ) {
        CLATeam *currentTeam = [UserDataManager getTeam];
        
        if (currentTeam.key != nil && currentTeam.key.intValue > 0) {
            for (CLATeamViewModel *teamViewModel in self.teamViewModelArray) {
                if (teamViewModel.team.key == currentTeam.key) {
                    return teamViewModel;
                }
            }
        }
        
        return self.teamViewModelArray[0];
    }
    
    return nil;
}

- (NSArray<CLATeamViewModel *> *)getTeams {
    return self.teamViewModelArray;
}

- (void)addOrUpdateTeam:(CLATeamViewModel *)teamViewModel {
    NSInteger foundIndex =
    [self findIndexForTeamKey:[teamViewModel.team.key intValue]];
    
    if (foundIndex >= 0) {
        [self.teamViewModelArray replaceObjectAtIndex:foundIndex
                                           withObject:teamViewModel];
    } else {
        [self.teamViewModelArray addObject:teamViewModel];
    }
}

- (void)deleteData {
    [self.teamViewModelArray removeAllObjects];
}

#pragma mark -
#pragma mark Priavte Methods

- (NSInteger)findIndexForTeamKey:(NSInteger)teamKey {
    NSInteger foundIndex = -1;
    
    for (int i = 0; i < self.teamViewModelArray.count; i++) {
        CLATeamViewModel *currentTeamViewModel =
        [self.teamViewModelArray objectAtIndex:i];
        if ([currentTeamViewModel.team.key intValue] == teamKey) {
            foundIndex = i;
            break;
        }
    }
    
    return foundIndex;
}

@end
