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
#import "LeftMenuViewController.h"
#import "ObjectThread.h"
#import "ChatThread+Category.h"
#import "DemoData.h"
#import "Constants.h"
#import "DateTools.h"

#import "CLATeam.h"
#import "CLARoom.h"
#import "CLAUser.h"
#import "CLATeamViewModel.h"

#import "CLASignalRMessageClient.h"

#import "MBProgressHUD.h"

static NSString * const kDefaultChatThread = @"collarabot";


@interface ChatViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftMenuButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightMenuButton;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) ChatThread *currentChatThread;

@property (nonatomic, strong) CLASignalRMessageClient *messageClient;

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
    [self initMenu];
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)connect {
    self.messageClient = [[CLASignalRMessageClient alloc] init];
    self.messageClient.delegate = self;
    [self.messageClient connect];
    
    
    self.senderId = self.messageClient.username;
    self.senderDisplayName = self.messageClient.username;
    self.username = self.messageClient.username;
}

#pragma mark -
#pragma mark - Menu Setup

- (void)initMenu {
    
    [self.leftMenuButton setTitle:@""];
    [self.leftMenuButton setWidth:30];
    [self.leftMenuButton setImage: [Constants chatIconImage]];
    
    
    [self.rightMenuButton setTitle:@""];
    [self.rightMenuButton setWidth:30];
    [self.rightMenuButton setImage: [Constants docIconImage]];
    
    
    UIBarButtonItem *chatThreadSetupButon = [[UIBarButtonItem alloc] initWithImage:[Constants infoIconImage] style:UIBarButtonItemStylePlain target:self action:@selector(ShowChatThreadSetupView)];
    [chatThreadSetupButon setTitle: @""];
    [chatThreadSetupButon setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItems arrayByAddingObject:chatThreadSetupButon];
}

#pragma mark - 
#pragma mark - Initial Setup

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
        [self initialzeCurrentThread];
    }
    
    [self.collectionView reloadData];
}

- (NSMutableArray *)getCurrentMessageThread {
    return (NSMutableArray *)[self.chatThreadRepository objectForKey:self.currentChatThread.title];
}

- (void)setCurrentMessageThread:(NSMutableArray *)messages  {
    [self.chatThreadRepository setObject:messages forKey:self.currentChatThread.title];
}

- (void)addMessage:(CLAMessage *)message toThread: (NSString*)threadTitle {
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
#pragma mark - Navigation

- (IBAction)leftMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (IBAction)rightMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToLeftAnimated:YES];
}


#pragma mark -
#pragma mark - Event handlers

- (IBAction)connectClicked:(id)sender
{
    //TODO: reconnect funcationality
    [self.messageClient reconnect];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    CLAMessage *message = [CLAMessage messageWithOId:nil SenderId:senderId displayName:senderDisplayName text:text];
    [self sendMessage:message];
}


- (void)didPressAccessoryButton:(UIButton *)sender {
    //TODO:implement
}

- (void)setupOutgoingTypingEventHandler {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)textFieldTextChanged:(id)sender {
    [self.messageClient sendTypingFromUser:self.username inRoom:self.currentChatThread.title];
}

#pragma mark -
#pragma mark - JSQMessages CollectionView DataSource

- (CLAMessage *)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
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
    
    CLAMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageView;
    }
    
    return self.incomingBubbleImageView;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CLAMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
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
        CLAMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    CLAMessage *message = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        CLAMessage *previousMessage = [[self getCurrentMessageThread] objectAtIndex:indexPath.item - 1];
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
    
    CLAMessage *msg = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    
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
    CLAMessage *currentMessage = [[self getCurrentMessageThread] objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        CLAMessage *previousMessage = [[self getCurrentMessageThread] objectAtIndex:indexPath.item - 1];
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

#pragma mark - JSQ Message Events
#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSMutableArray *chatThreads = [self getCurrentMessageThread];
    
    if (chatThreads != nil && chatThreads.count > 0){
        CLAMessage *earliestMessage = chatThreads[0];
        if (earliestMessage != nil)
        {
            self.showLoadEarlierMessagesHeader = false;
            [self.messageClient getPreviousMessages:earliestMessage.oId inRoom:self.currentChatThread.title];
        }
    }
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
#pragma mark Chat actions

- (void)didOpenConnection {
    
}

- (void)didReceiveTeams:(NSArray *)teams {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (teams == nil || teams.count == 0) {
        //TODO: show team creation page
    }
    
    CLATeamViewModel *teamViewModel = teams[0];
    
    if (teamViewModel == nil) {
        //TODO: show team creation page
    }
    
    
    NSMutableArray *chatThreadArray = [NSMutableArray array];
    for (CLARoom *room in teamViewModel.rooms) {
        ChatThread *thread= [[ChatThread alloc] init];
        thread.title = room.name;
        [chatThreadArray addObject:thread];
    }
    
    LeftMenuViewController *leftMenuViewController = (LeftMenuViewController *)self.slidingViewController.underLeftViewController;
    leftMenuViewController.chatThreads = chatThreadArray;
}

- (void)didReceiveMessage: (CLAMessage *) message inRoom:(NSString*)room {
    [self addMessage:message toThread:room];
    
    NSInteger secondApart = [message.date secondsFrom:[NSDate date]];
    
    BOOL animated = secondApart > -1 * kMessageLoadAnimateTimeThreshold ? TRUE : FALSE;
    
    //TODO: also show messages of the same user from other client in current thread
    if (message.senderId != self.username &&
        [[self.currentChatThread.title lowercaseString] isEqualToString:[room lowercaseString]]) {
        
        [self finishReceivingMessageAnimated:animated];
    }
}

- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room {
    if (![[user lowercaseString] isEqualToString: [self.username lowercaseString]]  &&
        [[self.currentChatThread.title lowercaseString] isEqualToString:[room lowercaseString]]) {
        
        self.showTypingIndicator = TRUE;
        [self scrollToBottomAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.showTypingIndicator = FALSE;
        });
    }
}

- (void)didLoadEarlierMessages:(NSArray *)earlierMessages inRoom:(NSString *)room {
    if (room == nil || earlierMessages == nil || earlierMessages.count == 0){
        self.showLoadEarlierMessagesHeader = FALSE;
        return;
    }
    
    NSArray *currentMessages = [self.chatThreadRepository objectForKey:room];
    
    NSMutableArray *aggregatedMessage = [NSMutableArray array];
    
    if (earlierMessages != nil && earlierMessages.count > 0) {
        [aggregatedMessage addObjectsFromArray:earlierMessages];
    }
    
    if (currentMessages != nil && currentMessages.count > 0) {

        [aggregatedMessage addObjectsFromArray:currentMessages];
    }
    
    earlierMessages = nil;
    currentMessages = nil;
    
    [self.chatThreadRepository setObject:aggregatedMessage forKey:room];
    
    BOOL animated = false;
    if ([[room lowercaseString] isEqualToString:[self.currentChatThread.title lowercaseString]])
    {
        animated = true;
    }
    
    [self finishReceivingMessageAnimated:animated];
    self.showLoadEarlierMessagesHeader = TRUE;
}


- (void)sendMessage: (id<JSQMessageData>)message {
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [[self getCurrentMessageThread] addObject:message];
    [self finishSendingMessageAnimated:TRUE];
    [self.messageClient sendMessage:message inRoom:self.currentChatThread.title];
}


-(void)initialzeCurrentThread {
    [self.messageClient loadRoom:self.currentChatThread.title];
}


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

#pragma mark -
#pragma mark View Controller Event Handlers

- (void)ShowChatThreadSetupView {
    NSLog(@"Show Setup View");
}

@end