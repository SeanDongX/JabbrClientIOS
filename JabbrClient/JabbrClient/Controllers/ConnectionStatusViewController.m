//
//  ConnectionStatusViewController.m
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "ConnectionStatusViewController.h"
#import "Router.h"

@implementation ConnectionStatusViewController

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
    [_connection stop];
    _hub = nil;
    _connection.delegate = nil;
    _connection = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(_data == nil)
    {
        _data = [NSMutableArray array];
    }
    
    [self startConnectionWithUserName:@"testclient" password:@"password"];
}

- (void)startConnectionWithUserName:(NSString *)username password: (NSString *)password {

    //NSString *username = @"testclient";
    //NSString *password = @"password";
    
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

- (void)startConnectionWithAuthToken:(NSString *)authToken {
    
    __weak __typeof(&*self)weakSelf = self;
    
    _connection = [SRHubConnection connectionWithURL:[Router sharedRouter].server_url queryString:[NSString stringWithFormat:@"token=%@", authToken]];
    
    [_connection prepareRequest: nil];
    _hub = [_connection createHubProxy:@"statushub"];
    [_hub on:@"joined" perform:self selector:@selector(joined:when:)];
    [_hub on:@"rejoined" perform:self selector:@selector(rejoined:when:)];
    [_hub on:@"leave" perform:self selector:@selector(leave:when:)];
    _connection.started = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:@"Connection Opened" atIndex:0];
        [strongSelf.tableView reloadData];
    };
    _connection.received = ^(NSDictionary * data){
        //__strong __typeof(&*weakSelf)strongSelf = weakSelf;
        //[strongSelf.data insertObject:data atIndex:0];
        //[self.tableView reloadData];
    };
    _connection.closed = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:@"Connection Closed" atIndex:0];
        [strongSelf.tableView reloadData];
    };
    _connection.error = ^(NSError *error){
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.data insertObject:error.localizedDescription atIndex:0];
        [strongSelf.tableView reloadData];
    };
    [_connection start];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Connection Status", @"Connection Status");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = (self.data)[indexPath.row];
    
    return cell;
}

#pragma mark - 
#pragma mark Connect Disconnect Sample Project

- (void)joined:(NSString *)connectionId when:(NSString *)when
{
    if([connectionId isEqualToString:self.connection.connectionId])
    {
        [self.data insertObject:[NSString stringWithFormat:@"I joined at: %@",when] atIndex:0];
    }
    else
    {
        [self.data insertObject:[NSString stringWithFormat:@"%@ joined at: %@",connectionId,when] atIndex:0];
    }
    [self.tableView reloadData];
}

- (void)rejoined:(NSString *)connectionId when:(NSString *)when
{
    [self.data insertObject:[NSString stringWithFormat:@"reconnected at: %@",when] atIndex:0];
    [self.tableView reloadData];
}

- (void)leave:(NSString *)connectionId when:(NSString *)when
{
    [self.data insertObject:[NSString stringWithFormat:@"%@ left at: %@", connectionId, when] atIndex:0];
    [self.tableView reloadData];
}

@end