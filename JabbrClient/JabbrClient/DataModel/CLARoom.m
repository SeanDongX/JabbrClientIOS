//
//  CLARoom.m
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLARoom.h"

//Util
#import "Constants.h"

@implementation CLARoom


- (NSString *)getHandle {
    return [CLARoom getHandle:self.name];
}

+ (NSString *)getHandle: (NSString *)roomName {
    return [NSString stringWithFormat:@"%@%@", kRoomPrefix, roomName];
}

@end
