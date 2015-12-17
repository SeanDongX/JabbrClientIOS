//
//  CLADisplayMessageFactory.h
//  Collara
//
//  Created by Sean on 04/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAMessage.h"
#import "Constants.h"

@interface CLADisplayMessageFactory : NSObject

+ (MessageType)getMessageType:(NSString *)text;
- (CLAMessage*)create:(CLAMessage *)message completionHandler:(void (^)())completion;

@end
