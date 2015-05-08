//
//  CLAWebApiClient.h
//  Collara
//
//  Created by Sean on 08/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAApiClient.h"

@interface CLAWebApiClient : NSObject <CLAApiClient>

+ (id)sharedInstance;

@end
