//
//  ChatThread+Category.m
//  JabbrClient
//
//  Created by Sean on 01/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "ChatThread+Category.h"

@implementation ChatThread (Category)

- (NSString *)getDisplayTitle {
    NSString *prefix = self.isDirectMessageThread ? @"@" : @"#";
    
    return [NSString stringWithFormat:@"%@%@", prefix, self.title];
}

@end
