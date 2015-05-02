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
@property (nonatomic) BOOL roomsLoaded;

- (void)sendMessage:(id<JSQMessageData>)message inRoom:(NSString *)room;
- (void)sendTypingFromUser:user inRoom:room;

- (void)SRConnectionDidOpen:(SRConnection *)connection;
- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data;
- (void)SRConnectionDidClose:(SRConnection *)connection;
- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error;

@end
