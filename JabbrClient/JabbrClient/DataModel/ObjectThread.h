//
//  ObjectThread.h
//  JabbrClient
//
//  Created by Sean on 29/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectThread : NSObject

@property (nonatomic, strong) NSUUID *oid;
@property (nonatomic, strong) NSString *title;


@end
