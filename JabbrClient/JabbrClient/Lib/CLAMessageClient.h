//
//  CLAChatClient.h
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import "CLAMessage.h"
#import "Constants.h"

// Data
#import "CLATeamViewModel.h"
#import "CLADataRepositoryProtocol.h"
#import "CLAInMemoryDataRepository.h"

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

- (void)loadRoom:(NSString *)room;
- (void)sendMessage:(CLAMessage *)message inRoom:(NSString *)room;
- (void)sendTypingFromUser:(NSString *)user inRoom:(NSString *)room;
- (void)getPreviousMessages:(NSString *)messageId inRoom:(NSString *)room;

- (void)createRoomWithType:(RoomType)roomType name:(NSString *)roomName
           completionBlock:(void (^)(NSError *))completion;
- (void)inviteUser:(NSString *)username inRoom:(NSString *)room;
- (void)joinRoom:(NSString *)room;
- (void)leaveRoom:(NSString *)room;

- (void)invokeGetTeam;
@end

/**
 *
 * The message client delegate by which message events are communicated.
 *
 **/
@protocol CLAMessageClientDelegate <NSObject>

/**
 * Tells the delegate that a message has been received.
 *
 * @param messageClient The message client that is informing the delegate.
 *
 * @param message The incoming message.
 *
 **/
- (void)didOpenConnection;
- (void)didConnectionChnageState:(CLAConnectionState)oldState
                        newState:(CLAConnectionState)newState;
- (void)didReceiveTeams:(NSArray *)teams;
- (void)didReceiveJoinRoom:(CLARoom *)room andUpdateRoom:(BOOL)update;
- (void)didReceiveUpdateRoom:(CLARoom *)room;
- (void)didReceiveMessage:(CLAMessage *)message inRoom:(NSString *)room;
- (void)didLoadEarlierMessages:(NSArray<CLAMessage> *)earlierMessages
                        inRoom:(NSString *)room;
- (void)didLoadUsers:(NSArray<CLAUser> *)users inRoom:(NSString *)room;
- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room;
- (void)reaplceMessageId:(NSString *)tempMessageId
           withMessageId:(NSString *)serverMessageId;
@optional

/**
 * Tells the delegate that a message for a specific recipient has been sent by
 * the local user.
 *
 * This method is called when a message is sent from
 * the local message client (i.e. -[SINMessageClient sendMessage:]).
 * This callback is triggered on all devices on which the local user is logged
 * in.
 *
 * @param message Message that was sent.
 *
 * @param recipientId Recipient of the message
 *
 * @see SINMessageClient, SINMessage
 */
- (void)messageSent:(CLAMessage *)message recipientId:(NSString *)recipientId;

/**
 * Tells the delegate that the message client failed to send a message.
 *
 * *Note*: Do not attempt to re-send the SINMessage received, instead,
 * create a new SINOutgoingMessage and send that.
 *
 * @param messageFailureInfo SINMessageFailureInfo object,
 *                            identifying the message and for which recipient
 *                            sending the message failed.
 *
 * @param message The message that could not be delivered.
 **/
- (void)messageFailed:(CLAMessage *)message
                 info:(id<CLAMessageFailureInfo>)messageFailureInfo;

/**
 * Tells the delegate that a message has been delivered (to a particular
 * recipient).
 *
 * @param info Info identifying the message that was delivered, and to whom.
 *
 **/
- (void)messageDelivered:(id<CLAMessageDeliveryInfo>)info;

/**
 * Tells the delegate that the receiver's device can't be reached directly,
 * and it is required to wake up the receiver's application with a push
 * notification.
 *
 * @param message    The message for which pushing is required.
 *
 * @param pushPairs  Array of SINPushPair. Each pair identififies a certain
 *                   device that should be requested to be woken up via
 *                   Apple Push Notification.
 *
 *                   The push data entries are equal to what the receiver's
 *                   application passed to the method
 *                   -[SINClient registerPushNotificationData:] method.
 *
 * @see SINPushPair
 *
 **/
- (void)message:(CLAMessage *)message
shouldSendPushNotifications:(NSArray *)pushPairs;

@end

/**
 * CLAMessageDeliveryInfo contains additional information pertaining
 * to a delivered message.
 *
 * @see -[CLAMessageClientDelegate messageDelivered:].
 */

@protocol CLAMessageDeliveryInfo <NSObject>

/** The message's identifier */
@property(nonatomic, readonly, copy) NSString *messageId;

/** The identifier of the recipient */
@property(nonatomic, readonly, copy) NSString *recipientId;

/** Server-side-based timestamp */
@property(nonatomic, readonly, copy) NSDate *timestamp;

@end

/**
 * CLAMessageFailureInfo contains additional information pertaining to
 * failing to send a message.
 * @see -[CLAMessageClientDelegate messageFailed:info:].
 */

@protocol CLAMessageFailureInfo <NSObject>

/** The message's identifier */
@property(nonatomic, readonly, copy) NSString *messageId;

/** The identifier of the recipient */
@property(nonatomic, readonly, copy) NSString *recipientId;

/** The error reason */
@property(nonatomic, readonly, copy) NSError *error;

@end
