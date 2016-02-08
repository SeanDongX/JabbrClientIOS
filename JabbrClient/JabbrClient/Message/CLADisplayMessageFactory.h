//
//  CLADisplayMessageFactory.h
//  Collara
//
//  Created by Sean on 04/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAMessageViewModel.h"
#import "Constants.h"

@interface CLADisplayMessageFactory : NSObject

+ (MessageType)getMessageType:(NSString *)text;
- (CLAMessageViewModel*)create:(CLAMessageViewModel *)message completionHandler:(void (^)())completion;

@end
