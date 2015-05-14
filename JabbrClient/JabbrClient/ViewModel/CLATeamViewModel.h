//
//  CLATeamViewModel.h
//  Collara
//
//  Created by Sean on 01/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

//Util
#import "ObjectiveCGenerics.h"

//Data Model
#import "CLATeam.h"
#import "CLAUser.h"
#import "CLARoom.h"

GENERICSABLE(CLATeamViewModel)

@interface CLATeamViewModel : NSObject<CLATeamViewModel>

@property (nonatomic, strong) CLATeam *team;
@property (nonatomic, strong) NSArray<CLARoom> *rooms;
@property (nonatomic, strong) NSArray<CLAUser> *users;

@end
