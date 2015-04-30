//
//  CLATeamViewModel.h
//  Collara
//
//  Created by Sean on 01/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLATeam.h"

@interface CLATeamViewModel : NSObject

@property (nonatomic, strong) CLATeam *team;
@property (nonatomic, strong) NSArray *rooms;
@property (nonatomic, strong) NSArray *users;

@end
