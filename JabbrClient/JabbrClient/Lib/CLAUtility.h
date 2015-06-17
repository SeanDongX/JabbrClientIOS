//
//  CLAUtility.h
//  Collara
//
//  Created by Sean on 08/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLAUtility : NSObject

+ (BOOL)isValidEmail:(NSString *)email;
+ (BOOL)isString:(NSString *)firstString caseInsensitiveEqualTo:(NSString *)secondString;

+ (id)getUserDefault: (NSString *)key;
@end
