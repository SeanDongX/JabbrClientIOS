//
//  CLADisplayMessageFactory.h
//  Collara
//
//  Created by Sean on 04/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAMessage.h"

@interface CLADisplayMessageFactory : NSObject

- (CLAMessage*)create:(CLAMessage *)message completionHandler:(void (^)())completion;

@end
