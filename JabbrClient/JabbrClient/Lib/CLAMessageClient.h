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

@protocol CLAMessageClient;
@protocol CLAMessageClientDelegate;

@protocol CLAMessageDeliveryInfo;
@protocol CLAMessageFailureInfo;


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

@property (nonatomic, weak) id<CLAMessageClientDelegate> delegate;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) BOOL connected;

- (void)connect;
- (void)reconnect;

- (void)loadRoom:(NSString *)room;
- (void)sendMessage:(CLAMessage *)message inRoom:(NSString *)room;
- (void)sendTypingFromUser:(NSString *)user inRoom:(NSString *)room;
- (void)getPreviousMessages:(NSString *)messageId inRoom:(NSString *)room;

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
- (void)didReceiveRooms: (NSArray *)rooms users:(NSArray *)users;
- (void)didReceiveMessage: (CLAMessage *) message inRoom:(NSString*)room;
- (void)didLoadEarlierMessages: (NSArray *) earlierMessages inRoom:(NSString*)room;
- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room;

@optional

/**
 * Tells the delegate that a message for a specific recipient has been sent by the local user.
 *
 * This method is called when a message is sent from
 * the local message client (i.e. -[SINMessageClient sendMessage:]).
 * This callback is triggered on all devices on which the local user is logged in.
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
- (void)messageFailed:(CLAMessage *)message info:(id<CLAMessageFailureInfo>)messageFailureInfo;

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
- (void)message:(CLAMessage *)message shouldSendPushNotifications:(NSArray *)pushPairs;

@end


/**
 * CLAMessageDeliveryInfo contains additional information pertaining
 * to a delivered message.
 *
 * @see -[CLAMessageClientDelegate messageDelivered:].
 */

@protocol CLAMessageDeliveryInfo <NSObject>

/** The message's identifier */
@property (nonatomic, readonly, copy) NSString *messageId;

/** The identifier of the recipient */
@property (nonatomic, readonly, copy) NSString *recipientId;

/** Server-side-based timestamp */
@property (nonatomic, readonly, copy) NSDate *timestamp;

@end

/**
 * CLAMessageFailureInfo contains additional information pertaining to
 * failing to send a message.
 * @see -[CLAMessageClientDelegate messageFailed:info:].
 */

@protocol CLAMessageFailureInfo <NSObject>

/** The message's identifier */
@property (nonatomic, readonly, copy) NSString *messageId;

/** The identifier of the recipient */
@property (nonatomic, readonly, copy) NSString *recipientId;

/** The error reason */
@property (nonatomic, readonly, copy) NSError *error;

@end
