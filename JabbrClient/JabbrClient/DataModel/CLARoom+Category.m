//
//  CLARoom+Category.m
//  Collara
//
//  Created by Sean on 04/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLARoom+Category.h"
#import "Constants.h"

@implementation CLARoom (Category)

- (NSString *)getDisplayTitle {
    return [NSString stringWithFormat:@"%@%@", kRoomPrefix, self.name];
}

@end
