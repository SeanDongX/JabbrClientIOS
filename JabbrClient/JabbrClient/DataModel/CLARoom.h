//
//  CLARoom.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

// Data Models
#import "CLAMessageViewModel.h"
#import "CLAUser.h"

@interface CLARoom : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic) BOOL isPrivate;
@property(nonatomic) BOOL isDirectRoom;
@property(nonatomic) BOOL closed;
@property(nonatomic) NSInteger unread;
@property(nonatomic, strong) NSArray<CLAUser *> *users;
@property(nonatomic, strong) NSArray<CLAUser *> *owners;
@property(nonatomic, strong) NSMutableArray<CLAMessageViewModel *> *messages;

- (void)getFromDictionary:(NSDictionary *)dictionary;

- (NSString *)getHandle;
@end
