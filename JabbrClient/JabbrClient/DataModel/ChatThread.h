//
//  ChatThread.h
//  JabbrClient
//
//  Created by Sean on 31/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "ObjectThread.h"

@interface ChatThread : ObjectThread
@property  (nonatomic) BOOL isDirectMessageThread;
@end
