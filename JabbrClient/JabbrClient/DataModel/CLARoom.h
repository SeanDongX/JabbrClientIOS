//
//  CLARoom.h
//  Collara
//
//  Created by Sean on 28/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"

//Data Models
#import "CLAMessage.h"
#import "CLAUser.h"


GENERICSABLE(CLARoom)

@interface CLARoom : NSObject<CLARoom>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL closed;
@property (nonatomic) NSInteger unread;
@property (nonatomic, strong) NSArray<CLAUser> *users;
@property (nonatomic, strong) NSArray<CLAUser> *owners;
@property (nonatomic, strong) NSMutableArray<CLAMessage> *messages;

- (void)getFromDictionary:(NSDictionary*)dictionary;

- (NSString *)getHandle;
+ (NSString *)getHandle: (NSString *)roomName;
@end
