//
//  CLAMessageParser.h
//  Collara
//
//  Created by Sean on 23/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "CLAMessage.h"

@interface CLAMessageParser : NSObject

- (void)getMessageData:(CLAMessage *)message completionHandler:(void (^)(UIImage *))completion;

@end
