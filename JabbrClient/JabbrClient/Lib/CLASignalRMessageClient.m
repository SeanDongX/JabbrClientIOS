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

@interface CLASignalRMessageClient()

@property (nonatomic, strong) SRHubConnection *connection;
@property (nonatomic, strong) SRHubProxy *hub;

@end

@implementation CLASignalRMessageClient

#pragma mark -
#pragma mark View Actions

- (void)connect
{
    if (!self.connection)
    {
        [self makeConnection];
    }
}

- (void)reconnect
{
    [self.connection stop];
    self.hub = nil;
    self.connection.delegate = nil;
    self.connection = nil;
    [self makeConnection];
}

- (void)makeConnection {
    
    NSString *server = [AuthManager sharedInstance].server_url;
    NSString *authToken = [[AuthManager sharedInstance] getCachedAuthToken];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *teamKey = [defaults objectForKey:kTeamKey];
    
    if (authToken == nil) {
        //TODO: show login screen
    }
    
    self.username = [[AuthManager sharedInstance] getUsername];
    
    if (teamKey != nil && teamKey.intValue > 0){
        self.connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"team=%d&token=%@", teamKey.intValue, authToken]];
    }
    else {
        self.connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"token=%@", authToken]];
    }
    
    self.hub = [self.connection createHubProxy:@"Chat"];
    
    [self.hub on:@"logOn" perform:self selector:@selector(logon:)];
//    [self.hub on:@"addUser" perform:self selector:@selector(addUser:)];
//    [self.hub on:@"leave" perform:self selector:@selector(leave:)];
    
    [self.hub on:@"addMessage" perform:self selector:@selector(incomingMessage:)];
//    [self.hub on:@"sendPrivateMessage" perform:self selector:@selector(sendPrivateMessage:)];
//    [self.hub on:@"updateActivity" perform:self selector:@selector(updateActivity:)];
    [self.hub on:@"setTyping" perform:self selector:@selector(setTyping:)];
    
    [self.hub on:@"roomLoaded" perform:self selector:@selector(roomLoaded:)];
    
    [self.connection setDelegate:self];
    [self.connection start];
    
    //TODO: make better connection indicator
    self.connected = TRUE;
}

#pragma mark -
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    [self.hub invoke:@"Join" withArgs:@[]];
    self.connected = TRUE;
    
    [self.hub invoke:@"GetTeams" withArgs:@[] completionHandler:^(id data){
        [self loadTeamData:data];
    }];
    
    [self.delegate didOpenConnection];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{

}

- (void)SRConnectionDidClose:(SRConnection *)connection
{

}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{

}

#pragma mark -
#pragma mark CLAMessageClient Protocol Methods

- (void)loadRoom:(NSString *)room {
    [self.hub invoke:@"LoadRooms" withArgs:@[@[room]]];
}

- (void)sendMessage:(id<JSQMessageData>)message inRoom:(NSString *)room {
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [messageData setObject:message.text forKey:@"content"];
    [messageData setObject:room forKey:@"room"];
    [self.hub invoke:@"Send" withArgs:@[messageData]];
}

- (void)sendTypingFromUser:(NSString *)user inRoom:(NSString *)room {
    [self.hub invoke:@"Typing" withArgs:@[room]];
}

- (void)getPreviousMessages:(NSString *)messageId inRoom:(NSString *)room{
    
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
#pragma mark Messag Processing Methods

- (void)logon:(NSArray *)data {

}

- (void)loadTeamData:(NSArray *)data
{
    if (data == nil || data.count == 0) {
        return;
    }
    
    NSDictionary *teamDictionary = data[0];
    CLATeam *team = [[CLATeam alloc] init];
    team.name = [teamDictionary objectForKey:@"Name"];
    team.key = [teamDictionary objectForKey:@"Key"];
    
    
    NSMutableArray *roomArray = [NSMutableArray array];
    NSArray *roomArrayFromDictionary = [teamDictionary objectForKey:@"Rooms"];
    if (roomArrayFromDictionary != nil && roomArrayFromDictionary.count > 0){
        
        for (id room in roomArrayFromDictionary) {
            NSDictionary *roomDictionary = room;
            CLARoom *claRoom = [[CLARoom alloc] init];
            claRoom.name = [roomDictionary objectForKey:@"Name"];
            
            [roomArray addObject:claRoom];
        }
    }
    
    NSMutableArray *userArray = [NSMutableArray array];
    NSArray *userArrayFromDictionary = [teamDictionary objectForKey:@"Users"];
    if (userArrayFromDictionary != nil && userArrayFromDictionary.count > 0){
        
        for (id user in userArrayFromDictionary) {
            NSDictionary *userDictionary = user;
            CLAUser *user = [[CLAUser alloc] init];
            user.name = [userDictionary objectForKey:@"Name"];
            [userArray addObject:user];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *teamKey = [defaults objectForKey:kTeamKey];
    
    //TODO:save some of the values
    if (team != nil && team.key != nil && team.key.intValue != teamKey.intValue){
        
        [defaults setObject:team.key forKey:kTeamKey];
        [defaults synchronize];
        
        [self reconnect];
    }
    
    [self.delegate didReceiveRooms:roomArray users:userArray];
}

- (void)incomingMessage:(NSArray *)data
{
    //Message data example
    //    {
    //        Content = hi;
    //        HtmlContent = "<null>";
    //        HtmlEncoded = 0;
    //        Id = "8111d548-2db7-420b-bb2e-7494c6205f56";
    //        ImageUrl = "<null>";
    //        MessageType = 0;
    //        Source = "<null>";
    //        User =     {
    //            Active = 1;
    //            AfkNote = "<null>";
    //            Country = "<null>";
    //            Flag = "<null>";
    //            Hash = "<null>";
    //            IsAdmin = 1;
    //            IsAfk = 0;
    //            LastActivity = "2015-03-25T22:02:03.8653739Z";
    //            Name = seanxd;
    //            Note = "some note, help";
    //            Status = Active;
    //        };
    //        UserRoomPresence = present;
    //        When = "2015-03-25T22:02:03.8809978+00:00";
    //    },
    //    TestRoom
    //  }
    
    if (!data && data.count <2)
    {
        return;
    }
    
    NSString *room = data[1];
    
    NSDictionary *messageDictionary = data[0];
    [self.delegate didReceiveMessage:[self getMessageFromRawData:messageDictionary] inRoom:room];
}

- (CLAMessage *)getMessageFromRawData:(NSDictionary *)messageDictionary
{
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

- (void)setTyping:(NSArray *)data
{
    
    if (!data && data.count <2)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *room = data[1];
        NSString *user = [userDictionary objectForKey:@"Name"];
        
        [self.delegate didReceiveTypingFromUser:user inRoom:room];
    }
}

- (void)roomLoaded:(NSArray *)data
{
    
    //    <__NSCFArray 0x7fb214346e20>(
    //    {
    //        Closed = 0;
    //        Count = 0;
    //        Name = PitchDemo;
    //        Owners =     (
    //                      seanxd
    //                      );
    //        Private = 0;
    //        RecentMessages =     (
    //                              {
    //                                  Content = send;
    //                                  HtmlContent = "<null>";
    //                                  HtmlEncoded = 0;
    //                                  Id = "182be5ef-d8a6-44b6-a18f-ea42f1a38813";
    //                                  ImageUrl = "<null>";
    //                                  MessageType = 0;
    //                                  Source = "<null>";
    //                                  User =             {
    //                                      Active = 0;
    //                                      AfkNote = "<null>";
    //                                      Country = "<null>";
    //                                      Flag = "<null>";
    //                                      Hash = "<null>";
    //                                      IsAdmin = 0;
    //                                      IsAfk = 0;
    //                                      LastActivity = "2015-04-03T01:11:59.493Z";
    //                                      Name = kate;
    //                                      Note = "<null>";
    //                                      Status = Offline;
    //                                  };
    //                                  UserRoomPresence = present;
    //                                  When = "2015-04-01T13:21:12.9563522+00:00";
    //                              },
    //                              {
    //                                  Content = "Boom! Check your docs, just created from my phone!";
    //                                  HtmlContent = "<null>";
    //                                  HtmlEncoded = 0;
    //                                  Id = "661e9b16-7831-443f-a41e-c66c4de03027";
    //                                  ImageUrl = "<null>";
    //                                  MessageType = 0;
    //                                  Source = "<null>";
    //                                  User =             {
    //                                      Active = 1;
    //                                      AfkNote = "<null>";
    //                                      Country = "<null>";
    //                                      Flag = "<null>";
    //                                      Hash = "<null>";
    //                                      IsAdmin = 0;
    //                                      IsAfk = 0;
    //                                      LastActivity = "2015-04-06T14:11:57.707Z";
    //                                      Name = Mike;
    //                                      Note = "<null>";
    //                                      Status = Active;
    //                                  };
    //                                  UserRoomPresence = present;
    //                                  When = "2015-04-03T14:52:25.9471504+00:00";
    //                              }
    //                              );
    //        Topic = "";
    //        Users =     (
    //                     {
    //                         Active = 0;
    //                         AfkNote = "<null>";
    //                         Country = "<null>";
    //                         Flag = "<null>";
    //                         Hash = "<null>";
    //                         IsAdmin = 1;
    //                         IsAfk = 0;
    //                         LastActivity = "2015-04-06T13:41:18.517Z";
    //                         Name = seanxd;
    //                         Note = "some note, help";
    //                         Status = Inactive;
    //                     },
    //                     {
    //                         Active = 1;
    //                         AfkNote = "<null>";
    //                         Country = "<null>";
    //                         Flag = "<null>";
    //                         Hash = "<null>";
    //                         IsAdmin = 0;
    //                         IsAfk = 0;
    //                         LastActivity = "2015-04-06T14:11:57.707Z";
    //                         Name = Mike;
    //                         Note = "<null>";
    //                         Status = Active;
    //                     }
    //                     );
    //        Welcome = "";
    //    }
    //                                 )
    //
    if (data == nil)
    {
        return;
    }
    
    NSDictionary *roomInfoDictionary = data[0];
    NSString *room = [roomInfoDictionary objectForKey:@"Name"];
    NSArray *recentMessageArray = [roomInfoDictionary objectForKey:@"RecentMessages"];

    NSMutableArray *earlierMessageArray = [NSMutableArray array];
    for(NSDictionary *messageDictionary in recentMessageArray) {
        [earlierMessageArray addObject:[self getMessageFromRawData:messageDictionary]];
    }
    
    [self.delegate didLoadEarlierMessages:earlierMessageArray inRoom:room];
    
        //TOOD: load users
}

@end
