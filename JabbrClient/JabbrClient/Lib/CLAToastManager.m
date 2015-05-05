//
//  CLAToastManager.m
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAToastManager.h"
#import "Constants.h"
#import "CRToast.h"

@implementation CLAToastManager

+ (void)showDefaultInfoToastWithText:(NSString *)text completionBlock:(void (^)(void))completion {
    
    NSMutableDictionary *toasOptions = [Constants toasOptions].mutableCopy;
    [toasOptions setObject:text forKey:kCRToastTextKey];
    toasOptions[kCRToastImageKey] = [Constants infoIconImage];
    [CRToastManager showNotificationWithOptions:toasOptions
                                completionBlock:completion];
}
@end
