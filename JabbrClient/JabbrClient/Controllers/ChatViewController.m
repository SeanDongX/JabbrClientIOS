//
//  ChatViewController.m
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "ChatViewController.h"

// Util
#import "AuthManager.h"
#import "ObjectThread.h"
#import "Constants.h"
#import "DateTools.h"
#import "MBProgressHUD.h"
#import "CLAUtility.h"
#import "MBProgressHUD.h"
#import "CLANotificationManager.h"

// Data Model
#import "CLATeam.h"
#import "CLARoom.h"
#import "CLAUser.h"
#import "CLATeamViewModel.h"
#import "CLARoomViewModel.h"

// View Controller
#import "UIViewController+ECSlidingViewController.h"
#import "LeftMenuViewController.h"
#import "CLACreateTeamViewController.h"
#import "CLATopicInfoViewController.h"

@interface ChatViewController ()

@property(nonatomic, strong) CLARoom *room;

@property(strong, nonatomic) CLARoomViewModel *roomViewModel;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenuButton;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *rightMenuButton;

@property(nonatomic, strong) CLASignalRMessageClient *messageClient;

@property(nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageView;
@property(nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageView;

@end

@implementation ChatViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self connect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMenu];
    [self configJSQMessage];
    
    [self setupOutgoingTypingEventHandler];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.messageClient == nil || self.messageClient.teamLoaded == FALSE) {
        [self showHud];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [CLANotificationManager dismiss];
    [super viewWillAppear:animated];
}

- (void)connect {
    self.messageClient = [CLASignalRMessageClient sharedInstance];
    self.messageClient.delegate = self;
    [self.messageClient connect];
    
    self.senderId = self.messageClient.username;
    self.senderDisplayName = self.messageClient.username;
}

#pragma mark -
#pragma mark - Public Methods

- (void)setActiveRoom:(CLARoom *)room {
    self.room = room;
    [self.messageClient joinRoom:room.name];
    [self switchToRoom:room];
}

- (void)didReceiveTeams:(NSArray *)teams {
    if (teams == nil || teams.count == 0 || teams[0] == nil) {
        [self showCreateTeamView];
        [self sendNoTeamEventNotification];
        return;
    }
    
    [self sendTeamUpdatedEventNotification];
}


- (void)didReceiveMessage:(CLAMessage *)message inRoom:(NSString *)room {
    [self addMessage:message toRoom:room];
    //[self sendLocalNotificationFor:message inRoom:room];
    
    NSInteger secondApart = [message.date secondsFrom:[NSDate date]];
    
    BOOL animated =
    secondApart > -1 * kMessageLoadAnimateTimeThreshold ? TRUE : FALSE;
    
    // TODO: also show messages of the same user from other client in current
    // thread
    if (![self isCurrentUser:message.senderId] && [self isCUrrentRoom:room]) {
        [self finishReceivingMessageAnimated:animated];
    }
    
    if (![room isEqualToString:self.room.name]) {
        [self addUnread:1 toRoom:room];
    }
}

- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room {
    if (![self isCurrentUser:user] && [self isCUrrentRoom:room]) {
        
        self.showTypingIndicator = TRUE;
        [self scrollToBottomAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
                           self.showTypingIndicator = FALSE;
                       });
    }
}

#pragma mark -
#pragma mark - Menu Setup

- (void)initMenu {
    [self.leftMenuButton setTitle:@""];
    [self.leftMenuButton setWidth:30];
    [self.leftMenuButton setImage:[Constants menuIconImage]];
    
    [self.rightMenuButton setTitle:@""];
    [self.rightMenuButton setWidth:30];
    [self.rightMenuButton setImage:[Constants topicSettingIcon]];
    self.rightMenuButton.target = self;
    self.rightMenuButton.action = @selector(showChatInfoView);
}

#pragma mark -
#pragma mark - Initial Setup

- (void)configJSQMessage {
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    self.showLoadEarlierMessagesHeader = YES;
    
    // TODO:show and implement attachment functionality
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    JSQMessagesBubbleImageFactory *bubbleImageFactory =
    [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageView =
    [bubbleImageFactory outgoingMessagesBubbleImageWithColor:
     [UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageView =
    [bubbleImageFactory incomingMessagesBubbleImageWithColor:
     [UIColor jsq_messageBubbleBlueColor]];
}

#pragma mark -
#pragma mark - Chat Thread Methods


- (void)switchToRoom:(CLARoom *)room {
    [CLAUtility setUserDefault:room.name forKey:kSelectedRoomName];
    [self showHud];
    self.title = self.room.displayName;
    [self initialzeCurrentThread];
    
    [self joinUserToRoomModel];
    [self.messageClient loadRoom:room.name];
    [self.collectionView reloadData];
}

- (void)joinUserToRoomModel {
    CLATeamViewModel *teamViewModel =
    [self.messageClient.dataRepository getDefaultTeam];
    CLAUser *currentUser =
    [teamViewModel findUser:[[AuthManager sharedInstance] getUsername]];
    [teamViewModel joinUser:currentUser toRoom:self.room.name];
    [self sendTeamUpdatedEventNotification];
}

- (CLARoom *)getRoom:(NSString *)roomName {
    return [[self.messageClient.dataRepository getDefaultTeam].rooms
            objectForKey:roomName];
}

- (NSMutableArray<CLAMessage> *)getCurrentRoomMessages {
    return [self getMessagesForRoom:self.room.name];
}

- (NSMutableArray<CLAMessage> *)getMessagesForRoom:(NSString *)roomName {
    return [self getRoom:roomName].messages;
}

- (void)addMessage:(CLAMessage *)message toRoom:(NSString *)roomName {
    if (!message) {
        return;
    }
    
    // default to current thead
    if (!roomName) {
        [[self getCurrentRoomMessages] addObject:message];
    } else {
        [[self getMessagesForRoom:roomName] addObject:message];
    }
}

#pragma mark -
#pragma mark - Navigation

- (IBAction)leftMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark -
#pragma mark - Event handlers

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    CLAMessage *message = [CLAMessage messageWithOId:[[NSUUID UUID] UUIDString]
                                            SenderId:senderId
                                         displayName:senderDisplayName
                                                text:text];
    [self sendMessage:message];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    // TODO:implement
}

- (void)setupOutgoingTypingEventHandler {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(textFieldTextChanged:)
     name:UITextViewTextDidChangeNotification
     object:nil];
}

- (void)textFieldTextChanged:(id)sender {
    [self.messageClient sendTypingFromUser:self.messageClient.username
                                    inRoom:self.room.name];
}

#pragma mark -
#pragma mark - JSQMessages CollectionView DataSource

- (CLAMessage *)collectionView:(JSQMessagesCollectionView *)collectionView
 messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<CLAMessage> *messages = [self getCurrentRoomMessages];
    if (messages == nil || messages.count < indexPath.item + 1) {
        return nil;
    }
    
    return [messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:
(JSQMessagesCollectionView *)
collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view
     * cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    CLAMessage *message =
    [[self getCurrentRoomMessages] objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageView;
    }
    
    return self.incomingBubbleImageView;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:
(JSQMessagesCollectionView *)
collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CLAMessage *message =
    [[self getCurrentRoomMessages] objectAtIndex:indexPath.item];
    return [JSQMessagesAvatarImageFactory
            avatarImageWithUserInitials:message.senderDisplayName
            backgroundColor:[Constants mainThemeContrastColor]
            textColor:[UIColor whiteColor]
            font:[UIFont systemFontOfSize:13.0f]
            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (NSAttributedString *)collectionView:
(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *displayDate = [self getMessageDisplayDateAt:indexPath];
    
    if (displayDate == nil) {
        return nil;
    }
    
    return [[JSQMessagesTimestampFormatter sharedFormatter]
            attributedTimestampForDate:displayDate];
}

- (NSAttributedString *)collectionView:
(JSQMessagesCollectionView *)collectionView
attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    CLAMessage *message =
    [[self getCurrentRoomMessages] objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        CLAMessage *previousMessage =
        [[self getCurrentRoomMessages] objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderId];
}

- (NSAttributedString *)collectionView:
(JSQMessagesCollectionView *)collectionView
attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[self getCurrentRoomMessages] count];
}

- (UICollectionViewCell *)collectionView:
(JSQMessagesCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)
    [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set
     *`self.collectionView.collectionViewLayout.messageBubbleFont` to the font you
     * want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on
     *`self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    CLAMessage *msg =
    [[self getCurrentRoomMessages] objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        } else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{
                                             NSForegroundColorAttributeName : cell.textView.textColor,
                                             NSUnderlineStyleAttributeName :
                                                 @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
                                             };
    }
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate
#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)
collectionViewLayout
heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDate *displayDate = [self getMessageDisplayDateAt:indexPath];
    
    if (displayDate == nil) {
        return 0.0f;
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:
(JSQMessagesCollectionView *)
collectionView layout:(JSQMessagesCollectionViewFlowLayout *)
collectionViewLayout
heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  iOS7-style sender name labels
     */
    CLAMessage *currentMessage =
    [[self getCurrentRoomMessages] objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        CLAMessage *previousMessage =
        [[self getCurrentRoomMessages] objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId]
             isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)
collectionViewLayout
heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

#pragma mark - JSQ Message Events
#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:
(JSQMessagesLoadEarlierHeaderView *)headerView
didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSMutableArray<CLAMessage> *messages = [self getCurrentRoomMessages];
    
    if (messages != nil && messages.count > 0) {
        CLAMessage *earliestMessage = [messages objectAtIndex:0];
        if (earliestMessage != nil) {
            self.showLoadEarlierMessagesHeader = false;
            [self.messageClient getPreviousMessages:earliestMessage.oId
                                             inRoom:self.room.name];
        }
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapCellAtIndexPath:(NSIndexPath *)indexPath
         touchLocation:(CGPoint)touchLocation {
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark -
#pragma mark CLAMessageClient Delegate Methods

- (void)didOpenConnection {
}

- (void)didConnectionChnageState:(CLAConnectionState)oldState
                        newState:(CLAConnectionState)newState {
    if (newState == CLAConnected) {
        // FIXME:when offline, this path is being taken periodically
        [self hideHud];
    } else {
        [self showHud];
    }
}

- (void)didReceiveJoinRoom:(CLARoom *)room andUpdateRoom:(BOOL)update {
    if (self.room == nil ||
        (room.name != nil && [self.room.name isEqual:room.name])) {
        return;
    }
    
    //FixMe: add room to left menu
    if (update != NO) {
        [self sendTeamUpdatedEventNotification];
    }
    
    SlidingViewController *slidingViewController = (SlidingViewController *)self.slidingViewController;
    
    // make sure room switch works both ways, ie, when chat view is active main
    // view or not
    if (slidingViewController != nil) {
        [slidingViewController switchToRoom:room];
    } else {
        [self switchToRoom:room];
    }
}

- (void)didReceiveUpdateRoom:(CLARoom *)room {
    [self sendTeamUpdatedEventNotification];
}

- (void)didLoadUsers:(NSArray *)users inRoom:(NSString *)room {
    if (room == nil || users == nil || users.count == 0) {
        return;
    }
    
    self.roomViewModel.users = users;
}

- (void)didLoadEarlierMessages:(NSArray<CLAMessage> *)earlierMessages
                        inRoom:(NSString *)room {
    NSInteger earlierMessageCount = earlierMessages.count;
    
    self.showLoadEarlierMessagesHeader =
    earlierMessageCount >= kLoadEarlierMessageCount;
    NSArray<CLAMessage> *currentMessages = [self getMessagesForRoom:room];
    
    if (room == nil || earlierMessages == nil || earlierMessageCount == 0) {
        [self hideHud];
        
        if (currentMessages.count == 0) {
            [CLANotificationManager
             showText:
             NSLocalizedString(
                               @"It's lonely here, invite someone and say hello.",
                               nil)
             forViewController:self
             withType:CLANotificationTypeMessage];
        }
        return;
    }
    
    // Cautious check to see if the message is has been loaded before
    NSInteger currentMessageCount = currentMessages.count;
    
    if (earlierMessages != nil && earlierMessages.count > 0 &&
        currentMessages != nil && currentMessages.count > 0) {
        
        CLAMessage *firstEarlierMessage = [earlierMessages objectAtIndex:0];
        
        for (int i = 0; i < currentMessages.count; i++) {
            CLAMessage *message = [currentMessages objectAtIndex:i];
            if ([message.oId isEqualToString:firstEarlierMessage.oId]) {
                [self hideHud];
                return;
            }
        }
    }
    
    NSMutableArray *aggregatedMessage = [NSMutableArray array];
    
    if (earlierMessages != nil && earlierMessages.count > 0) {
        [aggregatedMessage addObjectsFromArray:earlierMessages];
    }
    
    if (currentMessages != nil && currentMessages.count > 0) {
        
        [aggregatedMessage addObjectsFromArray:currentMessages];
    }
    
    earlierMessages = nil;
    currentMessages = nil;
    
    CLARoom *claRoom = [self getRoom:room];
    claRoom.messages = nil;
    claRoom.messages = aggregatedMessage;
    
    [self finishReceivingMessageAnimated:NO];
    
    // focus on the precise message before the newly loaded earlier messages
    if (earlierMessageCount > 0 && currentMessageCount > 0) {
        [self.collectionView
         scrollToItemAtIndexPath:
         [NSIndexPath indexPathForRow:earlierMessageCount - 1 inSection:0]
         atScrollPosition:UICollectionViewScrollPositionTop
         animated:NO];
    }
    
    [self hideHud];
}

- (void)reaplceMessageId:(NSString *)tempMessageId
           withMessageId:(NSString *)serverMessageId {
    
    NSMutableArray *currentMessages = [self getCurrentRoomMessages];
    
    for (CLAMessage *message in currentMessages) {
        if ([CLAUtility isString:message.oId
          caseInsensitiveEqualTo:tempMessageId]) {
            message.oId = serverMessageId;
            break;
        }
    }
}

#pragma mark -
#pragma mark Private Methods
- (void)sendMessage:(CLAMessage *)message {
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [[self getCurrentRoomMessages] addObject:message];
    [self finishSendingMessageAnimated:TRUE];
    [self.messageClient sendMessage:message inRoom:self.room.name];
}

- (void)initialzeCurrentThread {
    self.roomViewModel = [[CLARoomViewModel alloc] init];
    
    CLARoom *room = [[self.messageClient.dataRepository getDefaultTeam].rooms
                     objectForKey:self.room.name];
    
    self.roomViewModel.room = room;
}

#pragma mark -
#pragma mark Incoming message handlers

- (BOOL)shoudIgnoreIncoming:(NSDictionary *)data {
    if (!data) {
        return false;
    }
    
    NSString *room = [data objectForKey:@"room"];
    if ([self isCUrrentRoom:room]) {
        NSLog(@"Incoming message ingored since it is for a different thread");
        return true;
    }
    
    NSString *username = [data objectForKey:@"username"];
    if ([self isCurrentUser:username]) {
        NSLog(@"Incoming message ingored since from current user");
        return true;
    }
    
    return false;
}

- (void)setTyping:(NSArray *)data {
    
    if (!data && data.count < 2) {
        return;
    }
    
    NSDictionary *userDictionary = (NSDictionary *)data[0];
    if (userDictionary && [userDictionary objectForKey:@"Name"]) {
        NSString *room = (NSString *)data[1];
        NSString *userName = [userDictionary objectForKey:@"Name"];
        
        NSMutableDictionary *ignoreParamDictionary =
        [NSMutableDictionary dictionaryWithCapacity:2];
        [ignoreParamDictionary setObject:room forKey:@"room"];
        [ignoreParamDictionary setObject:userName forKey:@"username"];
        
        if ([self shoudIgnoreIncoming:ignoreParamDictionary]) {
            return;
        }
        
        self.showTypingIndicator = TRUE;
        [self scrollToBottomAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
                           self.showTypingIndicator = FALSE;
                       });
    }
}

#pragma mark -
#pragma mark View Controller Event Handlers

- (void)showChatInfoView {
    CLATopicInfoViewController *topicInfoView =
    [[CLATopicInfoViewController alloc] initWithRoom:self.roomViewModel];
    [self.navigationController pushViewController:topicInfoView animated:YES];
}

- (void)showCreateTeamView {
    SlidingViewController *slidingViewController =
    (SlidingViewController *)self.slidingViewController;
    [slidingViewController switchToCreateTeamView];
}

#pragma mark -
#pragma mark Private Methods

- (void)subscribeEvent {
    // TODO: subscribe envent to save current active thread when app goes to
    // background or terminated
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //    selector:@selector(appWillResignActive:)
    //    name:UIApplicationWillResignActiveNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //    selector:@selector(appWillTerminate:)
    //    name:UIApplicationWillTerminateNotification object:nil];
}

- (void)sendTeamUpdatedEventNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventTeamUpdated
                                                        object:nil
                                                      userInfo:nil];
}

- (void)sendNoTeamEventNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventNoTeam
                                                        object:nil
                                                      userInfo:nil];
}

- (void)sendReceiveUnreadEventNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventReceiveUnread
                                                        object:nil
                                                      userInfo:nil];
}

- (NSDate *)getMessageDisplayDateAt:(NSIndexPath *)indexPath {
    CLAMessage *currentMessage =
    [[self getCurrentRoomMessages] objectAtIndex:indexPath.item];
    
    if (indexPath.item == 0) {
        return currentMessage.date;
    } else {
        
        CLAMessage *previsousMessage =
        [[self getCurrentRoomMessages] objectAtIndex:indexPath.item - 1];
        if (currentMessage.date != nil && previsousMessage.date != nil &&
            [currentMessage.date secondsFrom:previsousMessage.date] >=
            kMessageDisplayTimeGap) {
            
            return currentMessage.date;
        }
    }
    
    return nil;
}

- (void)showHud {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHud {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (BOOL)isCUrrentRoom:(NSString *)room {
    return room != nil && self.room != nil &&
    [room caseInsensitiveCompare:self.room.name] == NSOrderedSame;
}

- (BOOL)isCurrentUser:(NSString *)user {
    return user != nil &&
    [user caseInsensitiveCompare:self.messageClient.username] ==
    NSOrderedSame;
}

- (void)addUnread:(NSInteger)count toRoom:(NSString *)roomName {
    CLARoom *room = [self getRoom:roomName];
    room.unread += count;
    [self sendReceiveUnreadEventNotification];
}

//- (void)sendLocalNotificationFor:(CLAMessage *)message inRoom:(NSString *)room
//{
//    if ([UIApplication sharedApplication].applicationState ==
//    UIApplicationStateActive) {
//        return;
//    }
//
//    //TODO: investigation if this is possible when app goes to background
//    UILocalNotification *localNotification = [[UILocalNotification alloc]
//    init];
//    localNotification.fireDate = [NSDate date];
//    localNotification.alertBody = [NSString stringWithFormat:@"%@%@ %@%@: %@",
//    kRoomPrefix, room, kUserPrefix, message.senderDisplayName, message.text];
//    localNotification.soundName=UILocalNotificationDefaultSoundName;
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    localNotification.applicationIconBadgeNumber = [[UIApplication
//    sharedApplication] applicationIconBadgeNumber] + 1;
//
//    NSDictionary *infoDict= @{
//                                kRoomName: room,
//                                kMessageId: message.oId
//                            };
//
//    localNotification.userInfo = infoDict;
//
//    localNotification.alertAction = @"Open App";
//    localNotification.hasAction = YES;
//
//    [[UIApplication sharedApplication]
//    scheduleLocalNotification:localNotification];
//}

@end