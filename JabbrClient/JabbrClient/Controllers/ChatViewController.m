//
//  ChatViewController.m
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "ChatViewController.h"
#import "Router.h"

@interface ChatViewController ()
{
    NSString *name;
    NSString *hash;
    NSString *room;
}

- (void)addUser:(id)user exists:(BOOL)exists;

@end

@implementation ChatViewController

@synthesize messageField, messageTable;

- (void)awakeFromNib
{
    [super awakeFromNib];
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
    [connection stop];
    hub = nil;
    connection.delegate = nil;
    connection = nil;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [messagesReceived count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = messagesReceived[indexPath.row];
    
    return cell;
}

#pragma mark - 
#pragma mark View Actions

- (IBAction)connectClicked:(id)sender
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
    connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"token=%@", authToken]];
    
    hub = [connection createHubProxy:@"Chat"];
    
    [hub setMember:@"focus" object:@YES];
    [hub setMember:@"unread" object:@0];
    
    [hub on:@"refreshRoom" perform:self selector:@selector(refreshRoom:)];
    [hub on:@"showRooms" perform:self selector:@selector(showRooms:)];
    [hub on:@"addMessageContent" perform:self selector:@selector(addMessageContent:content:)];
    [hub on:@"addMessage" perform:self selector:@selector(addMessage:)];
    [hub on:@"addUser" perform:self selector:@selector(addUser:exists:)];
    [hub on:@"changeUserName" perform:self selector:@selector(changeUserName:newUser:)];
    [hub on:@"sendPrivateMessage" perform:self selector:@selector(sendPrivateMessage:to:message:)];
    [hub on:@"sendMeMessage" perform:self selector:@selector(sendMeMessage:message:)];
    [hub on:@"leave" perform:self selector:@selector(leave:)];
    
    [connection setDelegate:self];
    [connection start];
    
    if(messagesReceived == nil)
    {
        messagesReceived = [[NSMutableArray alloc] init];
    }
}

- (IBAction)sendClicked:(id)sender
{
    [hub invoke:@"Send" withArgs:@[messageField.text]];
    [messageField setText:@""];
}

#pragma mark - 
#pragma mark Chat Sample Project

- (void)clearMessages
{
    [messagesReceived removeAllObjects];
    [messageTable reloadData];
}

- (void)refreshMessages
{
    [messageTable reloadData];
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
    [messagesReceived addObject:content];
    [self refreshMessages];
}

-(void)refreshRoom:(id)inRoom
{
    [self clearMessages];
    [self clearUsers];
    
    [hub invoke:@"GetUsers" withArgs:@[] completionHandler:^(id users) {
        for(id user in users)
        {
            if([user isKindOfClass:[NSDictionary class]]){
                [self addUser:user exists:TRUE];
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

- (void)addMessageContent:(id)id content:(id)content
{
    NSLog(@"addMessageContent");
}

- (void)addMessage:(NSArray *)messageData
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
    
    if (messageData.count >=2)
    {
        NSDictionary *messageDictionary = messageData[0];
        NSString *userName = @"Unknown";
        NSDictionary *userData = [messageDictionary objectForKey:@"User"];
        
        if (userData && [userData objectForKey:@"Name"])
        {
            userName = [userData objectForKey:@"Name"];
        }
        
        NSString *room = messageData[1];
        messageString = [NSString stringWithFormat:@"@%@ in %@: %@", userName, room, [messageDictionary objectForKey:@"Content"]];
    }
    
    [self addMessage: messageString type:@"message"],
    [self refreshMessages];
}

- (void)addUser:(id)user exists:(BOOL)exists
{
    NSString *userName = [NSString stringWithFormat:@"%@",user[@"Name"]];

    if(!exists && ([name isEqualToString:userName] == NO))
    {
        //NSString *userId = [NSString stringWithFormat:@"u-%@",[user objectForKey:@"Name"]];
        [self addMessage:[NSString stringWithFormat:@"%@ just entered %@",userName,room] type:nil];
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

- (void)sendPrivateMessage:(id)from to:(id)to message:(id)message
{
    [self addMessage:[NSString stringWithFormat:@"*%@* %@",from,message] type:@"pm"];
}

- (void)leave:(id)user
{
    NSString *userName = [NSString stringWithFormat:@"%@",user[@"Name"]];
    [self addMessage:[NSString stringWithFormat:@"%@ left the room",userName] type:nil];
}

#pragma mark - 
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    [messagesReceived insertObject:@"Connection Opened" atIndex:0];
    [hub invoke:@"Join" withArgs:@[]];
    [messageTable reloadData];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    //[messagesReceived insertObject:data atIndex:0];
    //[messageTable reloadData];
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    [messagesReceived insertObject:@"Connection Closed" atIndex:0];
    [messageTable reloadData];
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    //[messagesReceived insertObject:[NSString stringWithFormat:@"Connection Error: %@",error.localizedDescription] atIndex:0];
    //[messageTable reloadData];
}

@end