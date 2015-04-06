//
//  ChatViewController.m
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "ChatViewController.h"
#import "AuthManager.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ObjectThread.h"
#import "ChatThread+Category.h"
#import "DemoData.h"
#import "Constants.h"
#import "DateTools.h"

static NSString * const kDefaultChatThread = @"collabot";


@interface ChatViewController ()

//@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) ChatThread *currentChatThread;


@property (nonatomic, strong) SRHubConnection *connection;
@property (nonatomic, strong) SRHubProxy *hub;

@property (nonatomic, strong) NSMutableDictionary *chatThreadRepository;

@property (nonatomic, strong) JSQMessagesBubbleImage* incomingBubbleImageView;
@property (nonatomic, strong) JSQMessagesBubbleImage* outgoingBubbleImageView;

@end

@implementation ChatViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChatThread];
    [self setupChatRepository];
    [self configJSQMessage];
    
    [self setupOutgoingTypingEventHandler];
    [self connect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    self.showLoadEarlierMessagesHeader = YES;
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

#pragma mark - 
#pragma initial setup

- (void)setupChatThread {
    //Set deafult as collabot thread
    ChatThread *initialThread = [[DemoData sharedDemoData].chatThreads objectAtIndex:2];
    
    self.currentChatThread = initialThread;
    self.navigationItem.title  = [initialThread getDisplayTitle];
}

- (void)setupChatRepository {
    self.chatThreadRepository = [NSMutableDictionary dictionary];
}

- (void)configJSQMessage {
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageView = [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageView = [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
}
- (void)switchToChatThread:(ChatThread *)chatThread {
    
    self.currentChatThread = chatThread;
    self.navigationItem.title = [NSString stringWithFormat:@"#%@", self.currentChatThread.title];
    
    if (![self.chatThreadRepository objectForKey:self.currentChatThread.title]) {
        [self.chatThreadRepository setObject:[NSMutableArray array] forKey:self.currentChatThread.title];
    }
    
    [self.collectionView reloadData];
    
    [self loadCurrentThread];
}

- (NSMutableArray *)getCurrentMessageThread {
    return (NSMutableArray *)[self.chatThreadRepository objectForKey:self.currentChatThread.title];
}

- (void)addMessage:(id<JSQMessageData>)message toThread: (NSString*)threadTitle {
    if (!message) {
        return;
    }
    
    //default to current thead
    if (!threadTitle) {
        [[self getCurrentMessageThread] addObject:message];
    }
    else {
        //TODO:user dictionary to store message
        NSMutableArray* messages = [self.chatThreadRepository objectForKey:threadTitle];
        if (!message) {
            messages = [NSMutableArray array];
            [self.chatThreadRepository setObject:messages forKey:threadTitle];
        }
        
        [messages addObject:message];
    }
}

#pragma mark -
#pragma mark Navigation

- (IBAction)leftMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (IBAction)rightMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToLeftAnimated:YES];
}


#pragma mark -
#pragma mark Event handlers

- (IBAction)connectClicked:(id)sender
{
    [self reconnect];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    JSQMessage *message = [JSQMessage messageWithSenderId:senderId displayName:senderDisplayName text:text];
    [self sendMessage:message];
}


- (void)setupOutgoingTypingEventHandler {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)textFieldTextChanged:(id)sender {
   [self.hub invoke:@"Typing" withArgs:@[self.currentChatThread.title]];
}

#pragma mark -
#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageView;
    }
    
    return self.incomingBubbleImageView;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
    if ([[message.senderId lowercaseString] isEqualToString:[self.senderId lowercaseString]]) {
        return nil;
    }
    else {
        return [[DemoData sharedDemoData].avatars objectForKey:[message.senderId lowercaseString]];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [[self getCurrentMessageThread] objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self getCurrentMessageThread] count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate
#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [[self getCurrentMessageThread] objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    //TODO:cache CLAMessage, init with message id
    //[self.hub invoke:@"GetPreviousMessages" withArgs:@[@[firstMessageId]]];
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}


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
    
    if (authToken == nil) {
        //TODO: show login screen
    }
    
    self.username = [[AuthManager sharedInstance] getUsername];
    
    //TODO:get senderid and dispaly name from server
    self.senderId = self.username;
    self.senderDisplayName = self.username;
    
    self.connection = [SRHubConnection connectionWithURL:server queryString: [NSString stringWithFormat:@"token=%@", authToken]];
    
    self.hub = [self.connection createHubProxy:@"Chat"];
    
    [self.hub on:@"logOn" perform:self selector:@selector(logon:)];
    [self.hub on:@"addUser" perform:self selector:@selector(addUser:)];
    [self.hub on:@"leave" perform:self selector:@selector(leave:)];
    
    [self.hub on:@"addMessage" perform:self selector:@selector(incomingMessage:)];
    [self.hub on:@"sendPrivateMessage" perform:self selector:@selector(sendPrivateMessage:)];
    [self.hub on:@"updateActivity" perform:self selector:@selector(updateActivity:)];
    [self.hub on:@"setTyping" perform:self selector:@selector(setTyping:)];
    
    [self.hub on:@"roomLoaded" perform:self selector:@selector(threadLoaded:)];
    
    
    [self.connection setDelegate:self];
    [self.connection start];
    
    if([self getCurrentMessageThread] == nil)
    {
        [self.chatThreadRepository setObject:[NSMutableArray array] forKey:self.currentChatThread.title] ;
    }
}

#pragma mark - 
#pragma mark Chat actions

- (void)receiveMessage:(id<JSQMessageData>)message atThread: (NSString *)threadTitle {
    
    [self addMessage:message toThread:threadTitle];
    
    NSInteger secondApart = [message.date secondsFrom:[NSDate date]];
    
    BOOL animated = secondApart > -1 * kMessageLoadAnimateTimeThreshold ? TRUE : FALSE;
    
    //TODO: also show messages of the same user from other client in current thread
    if (message.senderId != self.username &&
        [[self.currentChatThread.title lowercaseString] isEqualToString:[threadTitle lowercaseString]]) {
        
        [self finishReceivingMessageAnimated:animated];
    }
}

- (void)sendMessage: (id<JSQMessageData>)message {
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [[self getCurrentMessageThread] addObject:message];
    [self finishSendingMessageAnimated:TRUE];
    [self sendMessageToServer:message];
}

- (void)sendMessageToServer: (id<JSQMessageData>)message {
    
    NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
    [messageData setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [messageData setObject:message.text forKey:@"content"];
    [messageData setObject:self.currentChatThread.title forKey:@"room"];
    [self.hub invoke:@"Send" withArgs:@[messageData]];
}


-(void)loadCurrentThread {

    [self.hub invoke:@"LoadRooms" withArgs:@[@[self.currentChatThread.title]]];
}

//-(void)refreshRoom:(id)inRoom
//{
//    [self clearMessages];
//    [self clearUsers];
//    
//    [self.hub invoke:@"GetUsers" withArgs:@[] completionHandler:^(id users) {
//        for(id user in users)
//        {
//            if([user isKindOfClass:[NSDictionary class]]){
//            //    [self addUser:user exists:TRUE];
//            }
//            [self refreshUsers];
//        }
//    }];
//    
//    [self addMessage:[NSString stringWithFormat:@"Entered %@",inRoom] type:@"notification"];
//}

//-(void)showRooms:(id)rooms
//{
//    if([rooms isKindOfClass:[NSArray class]])
//    {
//        if([rooms count] == 0)
//        {
//            [self addMessage:[NSString stringWithFormat:@"No rooms available"] type:@"notification"];
//        }
//        else
//        {
//            for (id r in rooms)
//            {
//                [self addMessage:[NSString stringWithFormat:@"%@ (%@)",r[@"Name"],r[@"Count"]] type:nil];
//            }
//        }
//    }
//}

#pragma mark -
#pragma mark Incoming message handlers


- (BOOL)shoudIgnoreIncoming:(NSDictionary*)data {
    if (!data) {
        return false;
    }
    
    NSString* room = [data objectForKey:@"room"];
    if (room && ![[room lowercaseString] isEqualToString:[self.currentChatThread.title lowercaseString]])
    {
        NSLog(@"Incoming message ingored since it is for a thread thread");
        return true;
    }
    
    NSString* username = [data objectForKey:@"username"];
    if (username && [[username lowercaseString] isEqualToString:[self.username lowercaseString]])
    {
        NSLog(@"Incoming message ingored since from current user");
        return true;
    }
    
    return false;
}

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

- (void)addRawMessage:(NSDictionary *)messageDictionary toThread:(NSString *)thread
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
    
    //add message id to data
    NSString *messageId = [messageDictionary objectForKey:@"Id"];
    
    //TOOD: get real sendId
    NSString *senderId = userName;
    
    NSMutableDictionary *ignoreParamDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [ignoreParamDictionary setObject:thread forKey:@"room"];
    [ignoreParamDictionary setObject:userName forKey:@"username"];
    
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:userName
                                                          date:date
                                                          text:[messageDictionary objectForKey:@"Content"]];
    
    [self receiveMessage: message atThread:thread];
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
    
    NSString *thread = data[1];
    
    NSDictionary *messageDictionary = data[0];
    [self addRawMessage:messageDictionary toThread:thread];
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
        NSString *room = data[1];
        NSString *userName = [userDictionary objectForKey:@"Name"];
        
        NSMutableDictionary *ignoreParamDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        [ignoreParamDictionary setObject:room forKey:@"room"];
        [ignoreParamDictionary setObject:userName forKey:@"username"];
        
        if ([self shoudIgnoreIncoming:ignoreParamDictionary])
        {
            return;
        }
        
        //TODO: update status
        
        //[self addMessage:[NSString stringWithFormat: @"@%@: %@", userName, [userDictionary objectForKey:@"Status"]] type:@"UpdateActivity"];
        //[self refreshMessages];
    }
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
        NSString *userName = [userDictionary objectForKey:@"Name"];
        
        NSMutableDictionary *ignoreParamDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        [ignoreParamDictionary setObject:room forKey:@"room"];
        [ignoreParamDictionary setObject:userName forKey:@"username"];
        
        if ([self shoudIgnoreIncoming:ignoreParamDictionary])
        {
            return;
        }
        
        self.showTypingIndicator = TRUE;
        [self scrollToBottomAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.showTypingIndicator = FALSE;
        });
    }
}

- (void)threadLoaded:(NSArray *)data
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
    
    NSArray *recentMessageArray = [roomInfoDictionary objectForKey:@"RecentMessages"];
    
   dispatch_async(dispatch_get_main_queue(), ^{
        for(NSDictionary *messageDictionary in recentMessageArray) {
            [self addRawMessage:messageDictionary toThread:self.currentChatThread.title];
        }
        
        //TOOD: load users
   });
    
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
    
    if (data == nil || data.count <1)
    {
        return;
    }
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *userName = [userDictionary objectForKey:@"Name"];
    //TODO: update status
        
//        [self addMessage:[NSString stringWithFormat: @"@%@ is inactive", userName] type:@"UserStatus"],
//        [self refreshMessages];
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

    if (data == nil || data.count <3)
    {
        return;
    }
    
    NSString *room = data[1];
    
    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        
        NSString *userName = [userDictionary objectForKey:@"Name"];
        
        NSMutableDictionary *ignoreParamDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        [ignoreParamDictionary setObject:room forKey:@"room"];
        [ignoreParamDictionary setObject:userName forKey:@"username"];
        
        if ([self shoudIgnoreIncoming:ignoreParamDictionary])
        {
            return;
        }
        
        //TODO: add user
        //[self addMessage:[NSString stringWithFormat: @"@%@ has joined", userName] type:@"UserJoinRoom"],
        //[self refreshMessages];
    }
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
    
    //TODO: show in PM thread;
    //[self addMessage:[NSString stringWithFormat: @"@%@ PM: %@", data[0], data[2]] type:@"PrivateMessage"],
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
    
    NSString *room = data[1];
    
    if (!room || ![room isEqualToString:self.currentChatThread.title])
    {
        return;
    }

    NSDictionary *userDictionary = data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"])
    {
        NSString *userName = [userDictionary objectForKey:@"Name"];
        
        NSMutableDictionary *ignoreParamDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        [ignoreParamDictionary setObject:room forKey:@"room"];
        [ignoreParamDictionary setObject:userName forKey:@"username"];
        
        if ([self shoudIgnoreIncoming:ignoreParamDictionary])
        {
            return;
        }

        //TOOD: udpate status;
//        [self addMessage:[NSString stringWithFormat: @"@%@ has left", userName] type:@"UserLeaveRoom"],
//        [self refreshMessages];
    }
}


#pragma mark - 
#pragma mark SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Colla Bot"
                                             senderDisplayName:@"Colla Bot"
                                                          date:[NSDate date]
                                                          text:[NSString stringWithFormat:@"Welcom %@", self.username]];
    [self receiveMessage:message atThread:self.currentChatThread.title];
    [self.hub invoke:@"Join" withArgs:@[]];
}

- (void)SRConnection:(SRConnection *)connection didReceiveData:(id)data
{
    //[messagesReceived insertObject:data atIndex:0];
    //[messageTable reloadData];
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
   JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Colla Bot"
                                             senderDisplayName:@"Colla Bot"
                                                         date:[NSDate date]
                                                         text:[NSString stringWithFormat:@"Goodbye %@", self.username]];
    [self receiveMessage:message atThread:self.currentChatThread.title];
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    //[messagesReceived insertObject:[NSString stringWithFormat:@"Connection Error: %@",error.localizedDescription] atIndex:0];
    //[messageTable reloadData];
}

@end