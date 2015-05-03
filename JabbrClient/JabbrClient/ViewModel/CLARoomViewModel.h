//
//  CLARoomViewModel.h
//  Collara
//
//  Created by Sean on 04/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLARoom.h"

@interface CLARoomViewModel : NSObject

@property (nonatomic, strong) CLARoom *room;
@property (nonatomic, strong) NSArray *users;

@end
