//
//  CLASignalRMessageClient.m
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLASignalRMessageClient.h"

#import "Constants.h"
#import "AuthManager.h"
#import "CLATeam.h"
#import "CLARoom.h"
#import "CLAUser.h"
#import "CLATeamViewModel.h"

@interface CLASignalRMessageClient()

@property (nonatomic, strong) SRHubConnection *connection;
@property (nonatomic, strong) SRHubProxy *hub;

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

+ (id) allocWithZone:(NSZone *)zone {
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

- (id) init {
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    self.roomRepository = [NSMutableDictionary dictionary];
    return self;
}


#pragma mark -
#pragma mark View Actions

- (void)connect {
    if (!self.connection)
    {
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
    
    NSString *authToken = [[AuthManager sharedInstance] getCachedAuthToken];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *teamKey = [defaults objectForKey:kTeamKey];
    
    if (authToken == nil) {
        //TODO: throw expcetion
    }
    
    self.username = [[AuthManager sharedInstance] getUsername];
    
    if (teamKey != nil && teamKey.intValue > 0){
        self.connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"team=%d&token=%@", teamKey.intValue, authToken]];
    }
    else {
        self.connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"token=%@", authToken]];
    }
    
    self.hub = [self.connection createHubProxy:@"Chat"];
    
    [self crateHubSubscription];
    
    [self.connection setDelegate:self];
    [self.connection start];
    //TODO: make better connection indicator
    self.connected = TRUE;
}

- (void)crateHubSubscription {
    [self.hub on:@"logOn" perform:self selector:@selector(logon:)];
    [self.hub on:@"replaceMessage" perform:self selector:@selector(replaceMessage:)];
    [self.hub on:@"addMessage" perform:self selector:@selector(incomingMessage:)];
    [self.hub on:@"setTyping" perform:self selector:@selector(setTyping:)];
    [self.hub on:@"roomLoaded" perform:self selector:@selector(roomLoaded:)];
    //TODO: show error msg when connection failed
    
    //[self.hub on:@"sendPrivateMessage" perform:self selector:@selector(sendPrivateMessage:)];
    //[self.hub on:@"updateActivity" perform:self selector:@selector(updateActivity:)];
}

#pragma mark -
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection {
    [self.hub invoke:@"Join" withArgs:@[]];
    self.connected = TRUE;
    
    [self invokeGetTeam];
    [self.delegate didOpenConnection];
}

- (void)SRConnectionWillReconnect:(id <SRConnectionInterface>)connection {
}

- (void)SRConnectionDidReconnect:(id <SRConnectionInterface>)connection {
}

- (void)SRConnection:(id <SRConnectionInterface>)connection didReceiveData:(id)data {
}

- (void)SRConnectionDidClose:(id <SRConnectionInterface>)connection {
}

- (void)SRConnection:(id <SRConnectionInterface>)connection didReceiveError:(NSError *)error {
}

- (void)SRConnection:(id <SRConnectionInterface>)connection didChangeState:(connectionState)oldState newState:(connectionState)newState {
    [self.delegate didConnectionChnageState:[self translateConnectionState:oldState] newState:[self translateConnectionState:newState]];
}

- (void)SRConnectionDidSlow:(id <SRConnectionInterface>)connection {
}

#pragma mark -
#pragma mark CLAMessageClient Protocol Methods

- (CLAConnectionState)getConnectionState {
    return [self translateConnectionState:self.connection.state];
}

- (CLAConnectionState)translateConnectionState: (connectionState)state {
    switch (state) {
        case connected :
            return CLAConnected;
            
        case connecting :
            return CLAConnecting;
            
        case reconnecting :
            return CLAReconnecting;
            
        default :
            return CLADisconnected;
    }
}


- (void)loadRoom:(NSString *)room {
    [self.hub invoke:@"LoadRooms" withArgs:@[@[room]]];
}

- (void)sendMessage:(CLAMessage *)message inRoom:(NSString *)room {
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:message.oId forKey:@"id"];
    
    [messageData setObject:message.text forKey:@"content"];
    [messageData setObject:room forKey:@"room"];
    [self.hub invoke:@"Send" withArgs:@[messageData]];
}

- (void)sendTypingFromUser:(NSString *)user inRoom:(NSString *)room {
    [self.hub invoke:@"Typing" withArgs:@[room]];
}

- (void)getPreviousMessages:(NSString *)messageId inRoom:(NSString *)room {
    
    if (messageId == nil) {
        return;
    }
    
    [self.hub invoke:@"GetPreviousMessages" withArgs:@[messageId] completionHandler:^(NSArray *data) {
        
        NSMutableArray *earlierMessageArray = [NSMutableArray array];
        
        if (data != nil && data.count > 0){
            for(NSDictionary *messageDictionary in data) {
                [earlierMessageArray addObject:[self getMessageFromRawData:messageDictionary]];
            }
        }
        
        [self.delegate didLoadEarlierMessages:earlierMessageArray inRoom:room];
    }];
}

#pragma mark -
#pragma mark Message Processing Methods

- (void)logon:(NSArray *)data {

}

- (void)loadTeamData:(NSArray *)data {
    self.roomsLoaded = TRUE;
    
    if (data == nil || data.count == 0) {
        [self.delegate didReceiveTeams:nil];
        return;
    }
    
    NSMutableArray<CLATeamViewModel> *teamViewModelArray = [NSMutableArray arrayWithCapacity:data.count];
    
    for (NSDictionary *teamDictionary in data) {
        CLATeamViewModel *teamViewModel = [CLATeamViewModel getFromData:teamDictionary];
        [teamViewModelArray addObject:teamViewModel];
    }
    
    if (teamViewModelArray.count > 0) {
        
        CLATeamViewModel *teamViewModel = teamViewModelArray[0];
        CLATeam *team = teamViewModel.team;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *teamKey = [defaults objectForKey:kTeamKey];
        
        if (team != nil && team.key != nil && team.key.intValue != teamKey.intValue){
            
            [defaults setObject:team.key forKey:kTeamKey];
            [defaults synchronize];
            
            [self reconnect];
        }
    }
    
    [self.delegate didReceiveTeams:teamViewModelArray];
}

- (void)incomingMessage:(NSArray *)data {
    if (!data && data.count <2)
    {
        return;
    }
    
    NSString *room = (NSString *)data[1];
    
    NSDictionary *messageDictionary = (NSDictionary *)data[0];
    [self.delegate didReceiveMessage:[self getMessageFromRawData:messageDictionary] inRoom:room];
}



- (void)replaceMessage:(NSArray *)data {
///{"C":"d-479787E6-A,0|B,7|C,0|D,7|E,0|F,2|G,2|H,6|I,2|J,2|K,2","M":[{"H":"Chat","M":"replaceMessage","A":["eb5e07e5-4327-86ee-20bd-e4556387ecd3",{"HtmlEncoded":false,"Id":"1b45008d-..."}...
    //TODO: mark message as sent
    if (!data && data.count <2)
    {
        return;
    }
    
    NSString *tempMessageId = (NSString *)data[0];
    
    NSDictionary *messageDictionary = (NSDictionary *)data[1];
    NSString *serverMessageId = [messageDictionary objectForKey:@"Id"];
    
    if (tempMessageId != nil && serverMessageId != nil) {
        [self.delegate reaplceMessageId:tempMessageId withMessageId: serverMessageId];
    }
}


- (CLAMessage *)getMessageFromRawData:(NSDictionary *)messageDictionary {
    NSString *userName = @"Unknown";
    NSDictionary *userData = [messageDictionary objectForKey:@"User"];
    
    NSString *dateString = [messageDictionary objectForKey:@"When"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    
    if (userData && [userData objectForKey:@"Name"])
    {
        userName = [[userData objectForKey:@"Name"] lowercaseString];
    }
    
    NSString *oId = [messageDictionary objectForKey:@"Id"];
    
    NSString *senderId = userName;
    
    return[[CLAMessage alloc] initWithOId:oId
                                 SenderId:senderId
                        senderDisplayName:userName
                                     date:date
                                     text:[messageDictionary objectForKey:@"Content"]];
}

- (void)setTyping:(NSArray *)data {
    if (!data && data.count <2)
    {
        return;
    }
    
    NSDictionary *userDictionary = (NSDictionary *)data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *room = (NSString *)data[1];
        NSString *user = [userDictionary objectForKey:@"Name"];
        
        [self.delegate didReceiveTypingFromUser:user inRoom:room];
    }
}

- (void)roomLoaded:(NSArray *)data {
    if (data == nil)
    {
        return;
    }
    
    NSDictionary *roomInfoDictionary = (NSDictionary *)data[0];
    NSString *room = [roomInfoDictionary objectForKey:@"Name"];
    
    
    NSArray *usersArray = [roomInfoDictionary objectForKey:@"Users"];
    NSMutableArray *users = [NSMutableArray array];
    
    for(NSDictionary *userDictionary in usersArray) {
        [users addObject:[CLAUser getFromData:userDictionary]];
    }
    
    [self.delegate didLoadUsers:users inRoom:room];
    
    NSArray *recentMessageArray = [roomInfoDictionary objectForKey:@"RecentMessages"];
    NSMutableArray *earlierMessageArray = [NSMutableArray array];
    
    for(NSDictionary *messageDictionary in recentMessageArray) {
        [earlierMessageArray addObject:[self getMessageFromRawData:messageDictionary]];
    }

    [self.delegate didLoadEarlierMessages:earlierMessageArray inRoom:room];
}


#pragma mark - 
#pragma mark - Join, Leave, Invite and etc. Commands

- (void)invokeCommand:(NSString *)comamndName withCommandParam:(NSString *)param fromRoom:(NSString *)room  {
    //{"H":"chat","M":"Send","A":[{"id":"40868be9-e5de-9fe1-77eb-f4f6a6b14972","content":"/invite mike","room":"TestRoom"}]...
    
    NSString *commandText = [NSString stringWithFormat: @"/%@ %@", comamndName, param];
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [messageData setObject:commandText forKey:@"content"];
    [messageData setObject:room forKey:@"room"];
    
    [self.hub invoke:@"Send" withArgs:@[messageData]];
}


- (void)createRoom:(NSString *)roomName completionBlock:(void (^)(NSError *)) completion{
    
    NSString *commandText = [NSString stringWithFormat: @"/%@ %@", @"create", roomName];
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [messageData setObject:commandText forKey:@"content"];
    [messageData setObject:@"lobby" forKey:@"room"];
    
    [self.hub invoke:@"Send" withArgs:@[messageData] complexCompletionHandler:^(id data, NSError *error){
        completion(error);
    }];
}

- (void)inviteUser:(NSString *)username inRoom:(NSString *)room; {
    //{"H":"chat","M":"Send","A":[{"id":"40868be9-e5de-9fe1-77eb-f4f6a6b14972","content":"/invite mike","room":"TestRoom"}]...
    [self invokeCommand:@"invite" withCommandParam:username fromRoom:room];
}

- (void)joinRoom:(NSString *)room {
    
    //{"H":"chat","M":"Send","A":[{"id":"883ea488-07eb-d63e-04d1-72bf8965c6f7","content":"/join testroom","room":"Welcome"}]...
    [self invokeCommand:@"join" withCommandParam:room fromRoom:@""];
}

- (void)leaveRoom:(NSString *)room {
    [self invokeCommand:@"leave" withCommandParam:room fromRoom:@""];
}

- (void)invokeGetTeam {
    [self.hub invoke:@"GetTeams" withArgs:@[] completionHandler:^(id data){
        [self loadTeamData:data];
    }];
}

@end
