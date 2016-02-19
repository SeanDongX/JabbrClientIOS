//
//  CLASignalRMessageClient.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignalRMessageClient.h"

// Util
#import "Constants.h"
#import "CLAUtility.h"
#import "UserDataManager.h"

// Data Model
#import "CLATeam.h"
#import "CLARoom.h"
#import "CLAUser.h"

// Repository
#import "CLARealmRepository.h"

@interface CLASignalRMessageClient ()

@property(nonatomic, strong) SRHubConnection *connection;
@property(nonatomic, strong) SRHubProxy *hub;

@end

@implementation CLASignalRMessageClient

#pragma mark -
#pragma mark Singleton

static CLASignalRMessageClient *SINGLETON = nil;
static bool isFirstAccess = YES;

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return [[CLASignalRMessageClient alloc] init];
}

- (id)mutableCopy {
    return [[CLASignalRMessageClient alloc] init];
}

- (id)init {
    if (SINGLETON) {
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    self.dataRepository = [[CLARealmRepository alloc] init];
    [self setupActicityTimer];
    //self.messageFactory = [[CLAMessageFactory alloc] init];
    return self;
}

- (void)setupActicityTimer {
    [NSTimer scheduledTimerWithTimeInterval:30
                                     target:self
                                   selector:@selector(updateActivity)
                                   userInfo:nil
                                    repeats:YES];
}

#pragma mark -
#pragma mark View Actions

- (void)connect {
    if (!self.connection) {
        [self makeConnection];
    }
}

- (void)disconnect {
    [self.connection stop];
    self.hub = nil;
    self.connection.delegate = nil;
    self.connection = nil;
}

- (void)reconnect {
    [self disconnect];
    [self makeConnection];
}

- (void)makeConnection {
    
    NSString *server = kServerBaseUrl;
    NSString *authToken = [UserDataManager getCachedAuthToken];
    NSNumber *teamKey = [UserDataManager getTeam].key;
    
    if (authToken == nil) {
        // TODO: throw expcetion
    }
    
    self.username = [UserDataManager getUsername];
    
    if (teamKey != nil && teamKey.intValue > 0) {
        self.connection =
        [SRHubConnection connectionWithURLString:server
                                     queryString:@{
                                                   @"team" : teamKey.stringValue,
                                                   @"token" : authToken
                                                   }];
    } else {
        self.connection = [SRHubConnection connectionWithURLString:server
                                                       queryString:@{
                                                                     @"token" : authToken
                                                                     }];
    }
    
    self.hub = [self.connection createHubProxy:@"Chat"];
    
    [self crateHubSubscription];
    
    [self.connection setDelegate:self];
    [self.connection start];
    // TODO: make better connection indicator
    self.connected = TRUE;
}

- (void)crateHubSubscription {
    [self.hub on:@"logOn" perform:self selector:@selector(logon:)];
    [self.hub on:@"replaceMessage"
         perform:self
        selector:@selector(replaceMessage:)];
    [self.hub on:@"addMessage" perform:self selector:@selector(incomingMessage:)];
    [self.hub on:@"setTyping" perform:self selector:@selector(setTyping:)];
    [self.hub on:@"roomLoaded" perform:self selector:@selector(roomLoaded:)];
    [self.hub on:@"joinRoom" perform:self selector:@selector(joinRoomReceived:)];
    [self.hub on:@"updateRoom"
         perform:self
        selector:@selector(updateRoomReceived:)];
    
    //[self.hub on:@"sendPrivateMessage" perform:self
    // selector:@selector(sendPrivateMessage:)];
    //[self.hub on:@"updateActivity" perform:self
    // selector:@selector(updateActivity:)];
}

#pragma mark -
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection {
    [self invokeHubMethod:@"Join" withArgs:@[] completionHandler:nil];
    self.connected = YES;
    
    [self invokeGetTeam];
    [self.delegate didOpenConnection];
}

- (void)SRConnectionWillReconnect:(id<SRConnectionInterface>)connection {
}

- (void)SRConnectionDidReconnect:(id<SRConnectionInterface>)connection {
}

- (void)SRConnection:(id<SRConnectionInterface>)connection
      didReceiveData:(id)data {
}

- (void)SRConnectionDidClose:(id<SRConnectionInterface>)connection {
    self.connected = NO;
}

- (void)SRConnection:(id<SRConnectionInterface>)connection
     didReceiveError:(NSError *)error {
    NSLog(@"Error %@", error.description);
}

- (void)SRConnection:(id<SRConnectionInterface>)connection
      didChangeState:(connectionState)oldState
            newState:(connectionState)newState {
    [self.delegate
     didConnectionChnageState:[self translateConnectionState:oldState]
     newState:[self translateConnectionState:newState]];
    
    NSLog(@"Connection state changed from %@ to %@", @(oldState), @(newState));
}

- (void)SRConnectionDidSlow:(id<SRConnectionInterface>)connection {
}

#pragma mark -
#pragma mark CLAMessageClient Protocol Methods

- (CLAConnectionState)getConnectionState {
    return [self translateConnectionState:self.connection.state];
}

- (CLAConnectionState)translateConnectionState:(connectionState)state {
    switch (state) {
        case connected:
            return CLAConnected;
            
        case connecting:
            return CLAConnecting;
            
        case reconnecting:
            return CLAReconnecting;
            
        default:
            return CLADisconnected;
    }
}

- (void)loadRoom:(NSString *)room {
    [self invokeHubMethod:@"LoadRooms" withArgs:@[@[ room ]] completionHandler:nil];
}

- (void)sendMessage:(CLAMessage *)message inRoom:(NSString *)room {
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:message.key forKey:@"id"];
    
    [messageData setObject:message.content forKey:@"content"];
    [messageData setObject:room forKey:@"room"];
    [self invokeHubMethod:@"Send" withArgs:@[ messageData ] completionHandler:nil];
}

- (void)sendTypingFromUser:(NSString *)user inRoom:(NSString *)room {
    [self invokeHubMethod:@"Typing" withArgs:@[ room ] completionHandler:nil];
}

- (void)getPreviousMessages:(NSString *)messageId inRoom:(NSString *)room {
    
    if (messageId == nil) {
        return;
    }
    
    __weak __typeof(&*self) weakSelf = self;
    
    [self invokeHubMethod:@"GetPreviousMessages"
                 withArgs:@[ messageId ]
        completionHandler:^(id response, NSError *error) {
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            
            if (response != nil) {
                NSArray *messages = response;
                if (messages != nil && messages.count > 0) {
                    [strongSelf.dataRepository addOrUpdateMessagesWithData:messages
                                                                  formRoom:room
                                                                completion:^{
                                                                    __strong __typeof(&*weakSelf) strongSelfInner = weakSelf;
                                                                    [strongSelfInner.delegate didLoadEarlierMessagesInRoom:room];
                                                                }];
                }
            }
        }];
}

#pragma mark -
#pragma mark Message Processing Methods

- (void)logon:(NSArray *)data {
}

- (void)loadTeamData:(NSArray *)data {
    self.teamLoaded = TRUE;
    
    if (data == nil || data.count == 0) {
        [self.delegate didReceiveTeams:0];
        return;
    }
    
    __weak __typeof(&*self) weakSelf = self;
    
    [self.dataRepository addOrUpdateTeamsWithData:data completion:^{
        __strong __typeof(&*weakSelf) strongSelf = weakSelf;
        
        //TOOD:optimize init default team, user
        [strongSelf.dataRepository getCurrentOrDefaultTeam];
        NSString *userName = [UserDataManager getUsername];
        CLAUser *user = [strongSelf.dataRepository getUserByName:userName];
        [UserDataManager cacheUser:user];
        [strongSelf.delegate didReceiveTeams:data.count];
    }];
}

- (void)incomingMessage:(NSArray *)data {
    if (!data && data.count < 2) {
        return;
    }
    
    NSString *room = (NSString *)data[1];
    
    NSDictionary *messageDictionary = (NSDictionary *)data[0];
    CLAMessage *message = [CLAMessage getFromData:messageDictionary forRoom:room];
    [self.dataRepository addOrgupdateMessage:message];
    [self.delegate didReceiveMessageInRoom:room];
}

- (void)replaceMessage:(NSArray *)data {
    ///{"C":"d-479787E6-A,0|B,7|C,0|D,7|E,0|F,2|G,2|H,6|I,2|J,2|K,2","M":[{"H":"Chat","M":"replaceMessage","A":["eb5e07e5-4327-86ee-20bd-e4556387ecd3",{"HtmlEncoded":false,"Id":"1b45008d-..."}...
    // TODO: mark message as sent
    if (!data && data.count < 2) {
        return;
    }
    
    NSString *tempMessageId = (NSString *)data[0];
    
    NSDictionary *messageDictionary = (NSDictionary *)data[1];
    NSString *serverMessageId = [messageDictionary objectForKey:@"Id"];
    
    if (tempMessageId != nil && serverMessageId != nil) {
        [self.delegate reaplceMessageId:tempMessageId
                          withMessageId:serverMessageId];
    }
}


- (void)setTyping:(NSArray *)data {
    if (!data && data.count < 2) {
        return;
    }
    
    NSDictionary *userDictionary = (NSDictionary *)data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"]) {
        NSString *room = (NSString *)data[1];
        NSString *user = [userDictionary objectForKey:@"Name"];
        
        [self.delegate didReceiveTypingFromUser:user inRoom:room];
    }
}

- (void)roomLoaded:(NSArray *)data {
    if (data == nil || data.count == 0) {
        return;
    }
    
    NSDictionary *roomInfoDictionary = (NSDictionary *)data[0];
    NSString *room = [roomInfoDictionary objectForKey:@"Name"];
    
    if (roomInfoDictionary == nil || roomInfoDictionary == (id)[NSNull null]) {
        return;
    }
    
    NSArray *roomDictionaryArray = [NSArray arrayWithObject:roomInfoDictionary];
    __weak __typeof(&*self) weakSelf = self;
    [self.dataRepository addOrUpdateRoomsWithData:roomDictionaryArray
                                       completion:^{
                                           __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                                           [strongSelf.delegate didLoadEarlierMessagesInRoom:room];
                                       }];
}

- (void)joinRoomReceived:(NSArray *)data {
    if (data == nil) {
        return;
    }
    
    //TODO:use realm
    NSDictionary *roomInfoDictionary = (NSDictionary *)data[0];
    CLARoom *room = [[CLARoom alloc] init];
    [CLARoom getFromData:roomInfoDictionary];
    
    CLATeam *team = [self.dataRepository getCurrentOrDefaultTeam];
    CLARoom *existingRoom = [team.rooms objectsWhere:@"name = %@", room.name].firstObject;
    
    NSString *username = [UserDataManager getUsername];
    __weak __typeof(&*self) weakSelf = self;
    
    if (!existingRoom) {
        [team.rooms addObject:room];
        NSArray *teamArray = [NSArray arrayWithObject:team];
        [self.dataRepository addOrUpdateRoomsWithData: teamArray completion:^{
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            [strongSelf.dataRepository joinUser:username toRoom:room.name inTeam:team.key];
            [strongSelf.delegate didReceiveJoinRoom:room.name andUpdateRoom:YES];
            return;
        }];
    }
    
    [self.dataRepository joinUser:username toRoom:room.name inTeam:team.key];
    [self.delegate didReceiveJoinRoom:room.name andUpdateRoom: NO];
}

- (void)updateRoomReceived:(NSArray *)data {
    if (data == nil) {
        return;
    }
    
    NSDictionary *roomInfoDictionary = (NSDictionary *)data[0];
    CLARoom *room = [CLARoom getFromData:roomInfoDictionary];
    NSArray *roomsArray = [NSArray arrayWithObject:roomInfoDictionary];
    
    __weak __typeof(&*self) weakSelf = self;
    [self.dataRepository addOrUpdateRoomsWithData: roomsArray
                                       completion: ^(void) {
                                           __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                                           [strongSelf.delegate didReceiveUpdateRoom:room.name];
                                       }];
}

- (void)errorReceviced:(NSString *)errorMessage {
    // TODO: call delegeate to show error message on UI
}

#pragma mark -
#pragma mark - Join, Leave, Invite and etc. Commands

- (void)invokeCommand:(NSString *)comamndName
     withCommandParam:(NSString *)param
             fromRoom:(NSString *)room {
    //{"H":"chat","M":"Send","A":[{"id":"40868be9-e5de-9fe1-77eb-f4f6a6b14972","content":"/invite
    // mike","room":"TestRoom"}]...
    
    NSString *commandText =
    [NSString stringWithFormat:@"/%@ %@", comamndName, param];
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [messageData setObject:commandText forKey:@"content"];
    [messageData setObject:room forKey:@"room"];
    
    [self invokeHubMethod:@"Send"
                 withArgs:@[ messageData ]
        completionHandler:^(id response, NSError *error) {
            if (error != nil) {
                [self errorReceviced:[NSString stringWithFormat: @"Send error for message %@", messageData]];
                [self reconnect];
                // TODO:check if there is internet, stop reconnect after a few tries
            }
        }];
}

- (void)createRoomWithType: (RoomType)roomType name:(NSString *)roomName
           completionBlock:(void (^)(NSError *))completion {
    NSString *command = @"create";
    
    switch (roomType) {
        case RoomTypePulbic:
            command = @"create";
            break;
            
        case RoomTypePrivate:
            command = @"createprivate";
            break;
            
        case RoomTypeDirect:
            command = @"createdirect";
            break;
            
        default:
            break;
    }
    
    NSString *commandText =
    [NSString stringWithFormat:@"/%@ %@", command, roomName];
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [messageData setObject:commandText forKey:@"content"];
    [messageData setObject:@"lobby" forKey:@"room"];
    
    [self invokeHubMethod:@"Send"
                 withArgs:@[ messageData ]
        completionHandler:^(id data, NSError *error) {
            completion(error);
        }];
}

- (void)inviteUser:(NSString *)username inRoom:(NSString *)room {
    //{"H":"chat","M":"Send","A":[{"id":"40868be9-e5de-9fe1-77eb-f4f6a6b14972","content":"/invite
    // mike","room":"TestRoom"}]...
    [self invokeCommand:@"invite"
       withCommandParam:[NSString stringWithFormat:@"%@ %@", username, room]
               fromRoom:@""];
}

- (void)joinRoom:(NSString *)room {
    //{"H":"chat","M":"Send","A":[{"id":"883ea488-07eb-d63e-04d1-72bf8965c6f7","content":"/join
    // testroom","room":"Welcome"}]...
    [self invokeCommand:@"join" withCommandParam:room fromRoom:@""];
}

- (void)leaveRoom:(NSString *)room {
    [self invokeCommand:@"leave" withCommandParam:room fromRoom:@""];
}

- (void)updateActivity {
    [self invokeHubMethod:@"updateActivity" withArgs:@[] completionHandler:nil];
}

- (void)invokeGetTeam {
    //Fixme: load team keys when log in and use in args
    [self invokeHubMethod:@"GetTeams"
                 withArgs:@[@0]
        completionHandler:^(id response, NSError *error) {
            if (error != nil) {
                [self errorReceviced:@"Loading error"];
                [self reconnect];
                // TODO:check if there is internet, stop reconnect after a few tries
            } else {
                if (response != nil) {
                    [self loadTeamData:response];
                }
            }
        }];
}


#pragma Private Methods

- (void)invokeHubMethod:(NSString *)method
               withArgs:(NSArray *)args
      completionHandler:(void (^)(id response, NSError *error))block {
    
    NSInteger retries = 0;
    NSInteger maxTries = 3;
    
    while (true) {
        @try {
            if (self.connected) {
                [self.hub invoke:method withArgs:args completionHandler:block];
            } else {
                NSLog(@"Error, connection is not on");
                
                if (block != nil) {
                    block(nil, [[NSError alloc] initWithDomain: @"Collara Connection Error" code: 100 userInfo: nil]);
                }
            }
            
            return;
        }
        @catch (NSException *e) {
            retries++;
            
            NSLog(@"Invoke %@ failed for the %ld time", method, (long)retries);
            
            if (retries >= maxTries) {
                return;
            }
            
            NSLog(@"Will retry");
        }
    }
    
    
}

@end
