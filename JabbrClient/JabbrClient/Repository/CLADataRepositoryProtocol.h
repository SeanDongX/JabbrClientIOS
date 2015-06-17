//
//  CLADataRepository.h
//  Collara
//
//  Created by Sean on 02/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLATeamViewModel.h"

@protocol CLADataRepositoryProtocol <NSObject>

-(CLATeamViewModel *)get:(NSString*)name;
-(CLATeamViewModel *)getDefaultTeam;
-(NSArray<CLATeamViewModel> *)getTeams;
-(void)addOrUpdateTeam:(CLATeamViewModel *)team;

@end
