//
//  ChatViewController.m
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "ChatViewController.h"
#import "Router.h"
#import "UIViewController+ECSlidingViewController.h"

@interface ChatViewController ()
{
    NSString *name;
    NSString *hash;
    NSString *room;
}

@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation ChatViewController

//@synthesize messageField, messageTable;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Navigation

- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (IBAction)reconnectButtonTapped:(id)sender {
    [self reconnect];
}

#pragma mark -
#pragma mark TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.messagesReceived count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.messagesReceived[indexPath.row];
    
    return cell;
}

#pragma mark - 
#pragma mark View Actions

- (void)makeConnection
{
    NSString *authToken = [self getCachedAuthToken];
    if (authToken) {
        [self connectWithAuthToken:authToken];
    }
    else {
        NSString *username = @"testclient";
        NSString *password = @"password";
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@account/login?ReturnUrl=/account/tokenr", [Router sharedRouter].server_url]]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        NSString *postString = [NSString stringWithFormat: @"username=%@&password=%@", username, password];
        
        NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        [request setValue:[NSString stringWithFormat:@"%ld", [data length]] forHTTPHeaderField:@"Content-Length"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse && [httpResponse statusCode] != 200) {
                                       NSLog(@"Token request error with code: %ld", [httpResponse statusCode]);
                                   }
                                   else if (data){
                                       NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       //remove "" from returned json string
                                       authToken = [authToken substringFromIndex:1];
                                       authToken = [authToken substringToIndex: [authToken length] - 1];
                                       [self cacheAuthToken:authToken];
                                       [self connectWithAuthToken:authToken];
                                       NSLog(@"Start conection using authtoken: %@", authToken);
                                   }
                               }];
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


- (void)connect
{
    if (!self.connection)
    {
        [self makeConnection];
    }
}

- (IBAction)connectClicked:(id)sender
{
    [self reconnect];
}

- (NSString *)getCachedAuthToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"authToken"];
}

- (void)cacheAuthToken: (NSString *)authToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authToken forKey:@"authToken"];
    [defaults synchronize];
}

- (void)connectWithAuthToken:(NSString *)authToken {
    
    
    NSString *server = [Router sharedRouter].server_url;
    self.connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"token=%@", authToken]];
    
    self.hub = [self.connection createHubProxy:@"Chat"];
    
    [self.hub on:@"logOn" perform:self selector:@selector(logon:)];
    [self.hub on:@"addUser" perform:self selector:@selector(addUser:)];
    [self.hub on:@"leave" perform:self selector:@selector(leave:)];
    
    [self.hub on:@"addMessage" perform:self selector:@selector(addMessage:)];
    [self.hub on:@"sendPrivateMessage" perform:self selector:@selector(sendPrivateMessage:)];
    [self.hub on:@"updateActivity" perform:self selector:@selector(updateActivity:)];
    [self.hub on:@"setTyping" perform:self selector:@selector(setTyping:)];
    
    //TOOD: fix subscriptions
    [self.hub setMember:@"focus" object:@YES];
    [self.hub setMember:@"unread" object:@0];
    
    [self.hub on:@"refreshRoom" perform:self selector:@selector(refreshRoom:)];
    [self.hub on:@"showRooms" perform:self selector:@selector(showRooms:)];
    [self.hub on:@"addMessageContent" perform:self selector:@selector(addMessageContent:content:)];
    [self.hub on:@"changeUserName" perform:self selector:@selector(changeUserName:newUser:)];

    [self.hub on:@"sendMeMessage" perform:self selector:@selector(sendMeMessage:message:)];
   
    [self.connection setDelegate:self];
    [self.connection start];
    
    if(self.messagesReceived == nil)
    {
        self.messagesReceived = [[NSMutableArray alloc] init];
    }
}

- (IBAction)sendClicked:(id)sender
{
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    
    [messageData setObject:self.messageField.text forKey:@"content"];
    
    //TODO: get room
    [messageData setObject:@"Welcome" forKey:@"room"];
    
    [self.hub invoke:@"Send" withArgs:@[messageData]];
    [self.messageField setText:@""];
}

#pragma mark - 
#pragma mark Chat Sample Project

- (void)clearMessages
{
    [self.messagesReceived removeAllObjects];
    [self.messageTable reloadData];
}

- (void)refreshMessages
{
    [self.messageTable reloadData];
}

- (void)clearUsers
{
    //[usersReceived removeAllObjects];
    //[userTable reloadData];
}

- (void)refreshUsers
{
    //[userTable reloadData];
}

- (void)addMessage:(NSString *)content type:(id)type
{
    [self.messagesReceived addObject:content];
    [self refreshMessages];
}

-(void)refreshRoom:(id)inRoom
{
    [self clearMessages];
    [self clearUsers];
    
    [self.hub invoke:@"GetUsers" withArgs:@[] completionHandler:^(id users) {
        for(id user in users)
        {
            if([user isKindOfClass:[NSDictionary class]]){
            //    [self addUser:user exists:TRUE];
            }
            [self refreshUsers];
        }
    }];
    
    [self addMessage:[NSString stringWithFormat:@"Entered %@",inRoom] type:@"notification"];
    room = inRoom;
}

-(void)showRooms:(id)rooms
{
    if([rooms isKindOfClass:[NSArray class]])
    {
        if([rooms count] == 0)
        {
            [self addMessage:[NSString stringWithFormat:@"No rooms available"] type:@"notification"];
        }
        else
        {
            for (id r in rooms)
            {
                [self addMessage:[NSString stringWithFormat:@"%@ (%@)",r[@"Name"],r[@"Count"]] type:nil];
            }
        }
    }
}

//- (void)addMessageContent:(id)id content:(id)content
//{
//    NSLog(@"addMessageContent");
//}


#pragma mark -
#pragma mark Response handlers

- (void)logon:(NSArray *)data {
//    <__NSCFArray 0x7fae4162a260>(
//    <__NSCFArray 0x7fae41625510>(
//    {
//        Closed = 0;
//        Count = 0;
//        Name = Welcome;
//        Owners = "<null>";
//        Private = 0;
//        RecentMessages = "<null>";
//        Topic = "<null>";
//        Users = "<null>";
//        Welcome = "<null>";
//    },
//    {
//        Closed = 0;
//        Count = 0;
//        Name = TestRoom;
//        Owners = "<null>";
//        Private = 0;
//        RecentMessages = "<null>";
//        Topic = "<null>";
//        Users = "<null>";
//        Welcome = "<null>";
//    }
//    )
//    ,
//    <__NSArrayI 0x7fae41731c00>(
//                                 
//    )
//    ,
//    {
//        TabOrder =     (
//                        Lobby,
//                        TestRoom,
//                        Welcome
//                        );
//    }
//)

    
}
- (void)addMessage:(NSArray *)data
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
    NSString *messageString = @"Error occured";
    
    if (data && data.count >=2)
    {
        NSDictionary *messageDictionary = data[0];
        NSString *userName = @"Unknown";
        NSDictionary *userData = [messageDictionary objectForKey:@"User"];
        
        if (userData && [userData objectForKey:@"Name"])
        {
            userName = [userData objectForKey:@"Name"];
        }
        
        NSString *room = data[1];
        messageString = [NSString stringWithFormat:@"@%@ #%@: %@", userName, room, [messageDictionary objectForKey:@"Content"]];
    }
    
    [self addMessage: messageString type:@"message"],
    [self refreshMessages];
}

- (void)updateActivity:(NSArray *)data
{
//    {
//        Active = 1;
//        AfkNote = "<null>";
//        Country = "<null>";
//        Flag = "<null>";
//        Hash = "<null>";
//        IsAdmin = 1;
//        IsAfk = 0;
//        LastActivity = "2015-03-25T23:48:24.2351142Z";
//        Name = seanxd;
//        Note = "some note, help";
//        Status = Active;
//    },
//    Welcome
//    )
    
    if (!data && data.count <2)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        [self addMessage:[NSString stringWithFormat: @"@%@ #%@: %@", [userDictionary objectForKey:@"Name"], data[1], [userDictionary objectForKey:@"Status"]] type:@"UpdateActivity"],
        [self refreshMessages];
    }
}

- (void)setTyping:(NSArray *)data
{
    //    {
    //        Active = 1;
    //        AfkNote = "<null>";
    //        Country = "<null>";
    //        Flag = "<null>";
    //        Hash = "<null>";
    //        IsAdmin = 1;
    //        IsAfk = 0;
    //        LastActivity = "2015-03-25T23:48:24.2351142Z";
    //        Name = seanxd;
    //        Note = "some note, help";
    //        Status = Active;
    //    },
    //    Welcome
    //    )
    
    if (!data && data.count <2)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        [self addMessage:[NSString stringWithFormat: @"@%@ #%@: typing...", [userDictionary objectForKey:@"Name"], data[1]] type:@"UserTyping"],
        [self refreshMessages];
    }
}

- (void)markInactive:(NSArray *)data
{
//    {
//        Active = 0;
//        AfkNote = "<null>";
//        Country = Barbados;
//        Flag = bb;
//        Hash = "<null>";
//        IsAdmin = 0;
//        IsAfk = 0;
//        LastActivity = "2015-03-25T22:53:59.973Z";
//        Name = testclient;
//        Note = "<null>";
//        Status = Inactive;
//    }
//    )
    
    if (!data && data.count <1)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *userName = [userDictionary objectForKey:@"Name"];
        [self addMessage:[NSString stringWithFormat: @"@%@ is inactive", userName] type:@"UserStatus"],
        [self refreshMessages];
    }
}

- (void)addUser:(NSArray *)data
{
//    {
//        Active = 1;
//        AfkNote = "<null>";
//        Country = "<null>";
//        Flag = "<null>";
//        Hash = "<null>";
//        IsAdmin = 1;
//        IsAfk = 0;
//        LastActivity = "2015-03-25T23:31:43.557Z";
//        Name = seanxd;
//        Note = "some note, help";
//        Status = Active;
//    },
//    Welcome,
//    1
//    )

    if (!data && data.count <3)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *userName = [userDictionary objectForKey:@"Name"];
        [self addMessage:[NSString stringWithFormat: @"@%@ has joined #%@", userName, data[1]] type:@"UserJoinRoom"],
        [self refreshMessages];
    }
}

- (void)changeUserName:(id)oldUser newUser:(id)newUser
{
    [self refreshUsers];
    NSString *newUserName = [NSString stringWithFormat:@"%@",newUser[@"Name"]];
    
    name = newUserName;
    
    if([newUserName isEqualToString:name])
    {
        [self addMessage:[NSString stringWithFormat:@"Your name is now %@",newUserName] type:@"notification"];
    }
    else
    {
        NSString *oldUserName = [NSString stringWithFormat:@"%@",oldUser[@"Name"]];
        [self addMessage:[NSString stringWithFormat:@"%@'s nick has changed to %@",oldUserName,newUserName] type:@"notification"];
    }
}

- (void)sendMeMessage:(id)inName message:(id)message
{
    [self addMessage:[NSString stringWithFormat:@"*%@* %@",inName,message] type:@"notification"];
}

- (void)sendPrivateMessage:(NSArray *)data
{
//    seanxd,
//    testclient,
//    this is a pm
    
    if (!data && data.count <3)
    {
        return;
    }
    
    [self addMessage:[NSString stringWithFormat: @"@%@ PM: %@", data[0], data[2]] type:@"PrivateMessage"],
    [self refreshMessages];
}

- (void)leave:(NSArray *)data
{
//    {
//        Active = 1;
//        AfkNote = "<null>";
//        Country = "<null>";
//        Flag = "<null>";
//        Hash = "<null>";
//        IsAdmin = 1;
//        IsAfk = 0;
//        LastActivity = "2015-03-25T23:27:21.903Z";
//        Name = seanxd;
//        Note = "some note, help";
//        Status = Active;
//    },
//    Welcome
//    )
    
    if (!data && data.count <2)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *userName = [userDictionary objectForKey:@"Name"];
        [self addMessage:[NSString stringWithFormat: @"@%@ has left #%@", userName, data[1]] type:@"UserLeaveRoom"],
        [self refreshMessages];
    }
}


#pragma mark - 
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    [self.messagesReceived insertObject:@"Connection Opened" atIndex:0];
    [self.hub invoke:@"Join" withArgs:@[]];
    [self.messageTable reloadData];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    //[messagesReceived insertObject:data atIndex:0];
    //[messageTable reloadData];
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    [self.messagesReceived insertObject:@"Connection Closed" atIndex:0];
    [self.messageTable reloadData];
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    //[messagesReceived insertObject:[NSString stringWithFormat:@"Connection Error: %@",error.localizedDescription] atIndex:0];
    //[messageTable reloadData];
}

@end