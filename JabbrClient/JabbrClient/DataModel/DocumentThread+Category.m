//
//  DocuemntThread+Category.m
//  JabbrClient
//
//  Created by Sean on 01/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "DocumentThread+Category.h"

@implementation DocumentThread (Category)

- (NSString *)getDisplayTitle {
    return [NSString stringWithFormat:@">%@", self.title];
}

@end
