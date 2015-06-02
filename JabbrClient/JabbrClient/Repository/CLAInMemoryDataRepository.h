//
//  DataRepository.h
//  Collara
//
//  Created by Sean on 02/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLADataRepositoryProtocol.h"
#import "CLATeamViewModel.h"

@interface CLAInMemoryDataRepository : NSObject <CLADataRepositoryProtocol>

-(CLATeamViewModel *)get:(NSString*)name;
-(CLATeamViewModel *)getDefaultTeam;
-(NSArray<CLATeamViewModel> *)getTeams;
-(void)addTeam:(CLATeamViewModel *)team;

@end
