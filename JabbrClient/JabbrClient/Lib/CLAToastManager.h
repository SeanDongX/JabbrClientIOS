//
//  CLAToastManager.h
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLAToastManager : NSObject

+ (void)showDefaultInfoToastWithText:(NSString *)text completionBlock:(void (^)(void))completion;

@end
