//
//  DocuemntThread+Category.m
//  JabbrClient
//
//  Created by Sean on 01/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "DocumentThread+Category.h"
#import "Constants.h"

@implementation DocumentThread (Category)

- (NSString *)getDisplayTitle {
    return [NSString stringWithFormat:@"%@%@", kDocPrefix, self.title];
}

@end
