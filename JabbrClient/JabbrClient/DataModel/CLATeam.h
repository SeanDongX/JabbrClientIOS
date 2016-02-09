//
//  CLATeam.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface CLATeam : RLMObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSNumber *key;
@end
