//
//  CLAUser+Category.m
//  Collara
//
//  Created by Sean on 04/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAUser+Category.h"
#import "Constants.h"

@implementation CLAUser (Category)

- (NSString *)getDisplayName {
    return [NSString stringWithFormat:@"%@%@", kUserPrefix, self.name];
}

@end
