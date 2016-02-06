//
//  CLARealmRepository.m
//  Collara
//
//  Created by Sean on 06/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLARealmRepository.h"

@implementation CLARealmRepository

- (CLAUser *)getUserByName: (NSString *)name {
    RLMResults<CLAUser *>  *users = [CLAUser objectsWhere:@"name = %@", name];
    return users[0];
}

@end
