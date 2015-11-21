//
//  DemoData.h
//  JabbrClient
//
//  Created by Sean on 01/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoData : NSObject

@property(nonatomic, strong) NSString *myUsername;
@property(nonatomic, strong) NSString *myPassword;
@property(nonatomic, strong) NSString *mySenderId;

@property(nonatomic, strong) NSMutableArray *documentThreads;
@property(nonatomic, strong) NSMutableArray *chatThreads;

+ (DemoData *)sharedDemoData;

@end
