//
//  ChatThread.h
//  JabbrClient
//
//  Created by Sean on 29/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatThread : NSObject

@property (nonatomic, strong) NSUUID *oid;
@property (nonatomic, strong) NSString *name;


@end
