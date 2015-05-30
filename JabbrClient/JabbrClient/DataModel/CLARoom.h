//
//  CLARoom.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"

GENERICSABLE(CLARoom)

@interface CLARoom : NSObject<CLARoom>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *owners;
@end
