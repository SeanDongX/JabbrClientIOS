//
//  ChatThread.h
//  JabbrClient
//
//  Created by Sean on 31/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "ObjectThread.h"

#import "ObjectiveCGenerics.h"

GENERICSABLE(ChatThread)

@interface ChatThread : ObjectThread<ChatThread>

@property  (nonatomic) BOOL isDirectMessageThread;

@end
