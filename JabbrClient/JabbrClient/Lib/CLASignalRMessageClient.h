//
//  CLASignalRMessageClient.h
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAMessageClient.h"
#import <JSQMessagesViewController/JSQMessages.h>

#import "SignalR.h"

@interface CLASignalRMessageClient : NSObject <CLAMessageClient, SRConnectionDelegate>

@property (nonatomic, weak) id<CLAMessageClientDelegate> delegate;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) BOOL connected;
@property (nonatomic, strong) id<CLADataRepositoryProtocol> dataRepository;
@property (nonatomic) BOOL teamLoaded;

+ (CLASignalRMessageClient*)sharedInstance;

@end
