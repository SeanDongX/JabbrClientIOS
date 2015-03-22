//
//  RawViewController.m
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "RawViewController.h"
#import "Router.h"

@implementation RawViewController

@synthesize meField, privateMessageField, privateMessageToField, messageField, messageTable;

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
    // Return YES for supported orientations
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
    NSString *username = @"testclient";
    NSString *password = @"password";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@account/login?ReturnUrl=/account/tokenr", [Router sharedRouter].server_url]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSString *postString = [NSString stringWithFormat: @"username=%@&password=%@", username, password];
    
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    [request setValue:[NSString stringWithFormat:@"%u", [data length]] forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               if (httpResponse && [httpResponse statusCode] != 200) {
                                   NSLog(@"Token request error with code: %d", [httpResponse statusCode]);
                               }
                               else if (data){
                                   NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //remove "" from returned json string
                                   authToken = [authToken substringFromIndex:1];
                                   authToken = [authToken substringToIndex: [authToken length] - 1];
                                   [self startConnectionWithAuthToken:authToken];
                                   NSLog(@"Start conection using authtoken: %@", authToken);
                               }
                           }];
}

- (void)startConnectionWithAuthToken: (NSString *)authToken {
    
    
    NSString *server = [Router sharedRouter].server_url;
    server = [server stringByAppendingFormat:@"signalr"];
    
    connection = [SRConnection connectionWithURL:server queryString:[NSString stringWithFormat:@"token=%@", authToken]];
    [connection setDelegate:self];
    [connection start];
    
    if(messagesReceived == nil)
    {
        messagesReceived = [[NSMutableArray alloc] init];
    }
}

- (IBAction)sendClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @0;
    message[@"value"] = meField.text;

    [connection send:message];
}

- (IBAction)broadcastClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @1;
    message[@"value"] = messageField.text;
    
    [connection send:message];
}

- (IBAction)enternameClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @2;
    message[@"value"] = messageField.text;
    
    [connection send:message];
}

- (IBAction)sendToUserClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @3;
    message[@"value"] = [NSString stringWithFormat:@"%@|%@",privateMessageToField.text,privateMessageField.text];
    
    [connection send:message];
}

- (IBAction)joingroupClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @4;
    message[@"value"] = messageField.text;

    [connection send:message];
}

- (IBAction)leavegroupClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @5;
    message[@"value"] = messageField.text;
    
   [connection send:message];
}

- (IBAction)sendToGroupClicked:(id)sender
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"type"] = @6;
    message[@"value"] = [NSString stringWithFormat:@"%@|%@",privateMessageToField.text,privateMessageField.text];
    
    [connection send:message];
}

- (IBAction)stopClicked:(id)sender
{
    [connection stop];
}

#pragma mark - 
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    [messagesReceived insertObject:@"Connection Opened" atIndex:0];
    [messageTable reloadData];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    if (data != nil) {
        if([data isKindOfClass:[NSDictionary class]]) {
            [messagesReceived insertObject:data[@"data"] atIndex:0];
        } else {
            [messagesReceived insertObject:[NSString stringWithFormat:@"%@",data] atIndex:0];
        }
        [messageTable reloadData];
    }
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    [messagesReceived insertObject:@"Connection Closed" atIndex:0];
    [messageTable reloadData];
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    //  NSLog(error);
    //[messagesReceived insertObject:[NSString stringWithFormat:@"Connection Error: %@",error.localizedDescription] atIndex:0];
    //[messageTable reloadData];
}

@end
