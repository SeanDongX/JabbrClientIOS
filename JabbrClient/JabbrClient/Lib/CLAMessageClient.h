//
//  CLAChatClient.h
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

// Data
#import "CLADataRepositoryProtocol.h"

@protocol CLAMessageClient;
@protocol CLAMessageClientDelegate;

@protocol CLAMessageDeliveryInfo;
@protocol CLAMessageFailureInfo;

typedef enum {
    CLAConnecting,
    CLAConnected,
    CLAReconnecting,
    CLADisconnected
} CLAConnectionState;

@protocol CLAMessageClient <NSObject>

/**
 * Assigns a delegate to the Message Client.
 *
 * Applications implementing instant messaging should assign a delegate
 * adopting the SINMessageClientDelegate protocol. The delegate will be
 * notified when messages arrive and receive message status updates.
 *
 * @see SINMessageClientDelegate
 */

@property(nonatomic, weak) id<CLAMessageClientDelegate> delegate;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) id<CLADataRepositoryProtocol> dataRepository;
@property(nonatomic) BOOL teamLoaded;

- (void)connect;
- (void)disconnect;
- (void)reconnect;

- (CLAConnectionState)getConnectionState;

- (void)loadRooms:(NSArray *)rooms;
- (void)sendMessage:(CLAMessage *)message inRoom:(NSString *)room;
- (void)sendTypingFromUser:(NSString *)user inRoom:(NSString *)room;
- (void)getPreviousMessages:(NSString *)messageId inRoom:(NSString *)room;

- (void)createRoomWithType:(RoomType)roomType name:(NSString *)roomName
           completionBlock:(void (^)(NSError *))completion;
- (void)inviteUser:(NSString *)username inRoom:(NSString *)room;
- (void)joinRoom:(NSString *)room;
- (void)leaveRoom:(NSString *)room;

- (void)updateActivity; //TODO: call this when user interact with the app
- (void)invokeGetTeam;
@end


@protocol CLAMessageClientDelegate <NSObject>

- (void)didOpenConnection;
- (void)didConnectionChnageState:(CLAConnectionState)oldState
                        newState:(CLAConnectionState)newState;
- (void)didReceiveTeams:(NSInteger)count;
- (void)didReceiveJoinRoom:(NSString *)room andUpdateRoom:(BOOL)update;
- (void)didAddUser:(NSString *)username toRoom:(NSString*)room;
- (void)didReceiveUpdateRoom:(NSString *)room;
- (void)didReceiveMessageInRoom:(NSString *)room;
- (void)didLoadEarlierMessagesInRoom:(NSString *)room;
//- (void)didLoadUsers:(NSArray<CLAUser *> *)users inRoom:(NSString *)room;
- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room;
- (void)replaceMessageId:(NSString *)tempMessageId
           withMessageId:(NSString *)serverMessageId;
@end