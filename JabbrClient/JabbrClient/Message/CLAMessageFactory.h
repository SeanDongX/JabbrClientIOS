//
//  CLAMessageFactory.h
//  Collara
//
//  Created by Sean on 02/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAMessage.h"

@interface CLAMessageFactory : NSObject

- (CLAMessage*)create:(NSDictionary *)messageDictionary;

@end
