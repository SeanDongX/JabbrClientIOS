//
//  CLANotification.h
//  Collara
//
//  Created by Sean on 11/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLANotification : NSObject

@property(strong, nonatomic) NSString *alert;
@property(strong, nonatomic) NSString *appUrl;

- (instancetype)init:(NSDictionary *)dictionary;

@end
