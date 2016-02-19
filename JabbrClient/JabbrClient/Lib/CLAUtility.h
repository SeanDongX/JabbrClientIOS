//
//  CLAUtility.h
//  Collara
//
//  Created by Sean on 08/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface CLAUtility : NSObject

+ (BOOL)isValidEmail:(NSString *)email;
+ (BOOL)isString:(NSString *)firstString caseInsensitiveEqualTo:(NSString *)secondString;

+ (NSString *)getUrlString:(UIImage *)image;
+ (NSDictionary *)getImagePostData:(UIImage *)image imageName:(NSString *)imageName fromRoom:(NSString *)roomName;
+ (NSMutableArray *)getArrayFromRLMArray:(RLMResults *)rlmResult;

@end
