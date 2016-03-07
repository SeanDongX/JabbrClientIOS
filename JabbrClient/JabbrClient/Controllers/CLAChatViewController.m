//
//  CLAChatViewController.m
//  Collara
//
//  Created by Sean on 10/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLAChatViewController.h"
#import "CLASignalRMessageClient.h"
#import "CLARealmRepository.h"

#import "UIViewController+ECSlidingViewController.h"
#import "MessageTextView.h"
#import "MessageTableViewCell.h"
#import "CLANotificationManager.h"
#import "UserDataManager.h"
#import "SlidingViewController.h"
#import "CLAUtility.h"
#import "CLAMediaManager.h"
#import "CLAWebApiClient.h"
#import "CLATopicInfoViewController.h"
#import "CLATaskWebViewController.h"
#import "UIScrollView+InfiniteScroll.h"
#import "CLAAzureHubPushNotificationService.h"

@interface CLAChatViewController ()

@property(weak, nonatomic) IBOutlet UIBarButtonItem *leftMenuButton;

@property(nonatomic, strong) id<CLAMessageClient> messageClient;

@property(nonatomic, strong) CLARoom *room;
@property(nonatomic, strong) CLAUser *user;
@property(nonatomic, strong) RLMArray<CLAUser *> *teamUsers;

@property(nonatomic, strong) NSIndexPath *selectedCellIndexPath;
@property(nonatomic, strong) CLATaskWebViewController *taskViewController;
#pragma mark -
#pragma mark - Slack View Controller components

@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic, weak) CLAMessage *editingMessage;

@end

@implementation CLAChatViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self connect];
    
    //needs to be call here instead of viewDidLoad due to unknow reason of caused by method swizzling in "UIScrollView+InfiniteScroll.h"
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initMenu];
    [self setupSlackViewController];
    [self setupPullToRefresh];
}

- (void)setupPullToRefresh {
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    //need to add bottom infinity scroll to simulator top pull to scroll, due to the table view here is inverted by slack view controller;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        [self refreshTriggered];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = self.room.displayName;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
}

- (void)initData {
    self.user = [UserDataManager getUser];
}

- (void)initMenu {
    [self.leftMenuButton setTitle:@""];
    [self.leftMenuButton setWidth:30];
    [self.leftMenuButton setImage:[Constants menuIconImage]];
    self.leftMenuButton.target = self;
    self.leftMenuButton.action = @selector(showLeftMenu);
    
    UIBarButtonItem *optionsItem = [[UIBarButtonItem alloc] initWithImage:[Constants optionsIconImage]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(showRightMenu)];
    optionsItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[optionsItem];
}

- (void)setupSlackViewController {
    
    // SLKTVC's configuration
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    [self.leftButton setImage:[Constants cameraIcon] forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor grayColor]];
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    self.textInputbar.textView.placeholder = NSLocalizedString(@"Type a message...", nil);
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editorLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editorRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
#if !DEBUG_CUSTOM_TYPING_INDICATOR
    self.typingIndicatorView.canResignByTouch = YES;
#endif
    
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    [self.autoCompletionView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    [self registerPrefixesForAutoCompletion:@[@"@", @"#"]];
    
    //    [self.textView registerMarkdownFormattingSymbol:@"*" withTitle:@"Bold"];
    //    [self.textView registerMarkdownFormattingSymbol:@"_" withTitle:@"Italics"];
    //    [self.textView registerMarkdownFormattingSymbol:@"~" withTitle:@"Strike"];
    //    [self.textView registerMarkdownFormattingSymbol:@"`" withTitle:@"Code"];
    //    [self.textView registerMarkdownFormattingSymbol:@"```" withTitle:@"Preformatted"];
    //    [self.textView registerMarkdownFormattingSymbol:@">" withTitle:@"Quote"];
}

- (void)connect {
    self.messageClient = [CLASignalRMessageClient sharedInstance];
    self.messageClient.delegate = self;
    [self.messageClient connect];
}

#pragma mark -
#pragma mark - Public Methods

- (void)showInfoView {
    CLATopicInfoViewController *topicInfoView =
    [[CLATopicInfoViewController alloc] initWithRoom:self.room];
    [self.navigationController pushViewController:topicInfoView animated:YES];
}

- (void)showCreateTeamView {
    [[self getSlidingViewController] switchToCreateTeamView:nil
                                       sourceViewIdentifier:nil];
}

- (void)showTaskView {
    if (self.taskViewController == nil) {
        self.taskViewController = [[CLATaskWebViewController alloc] init];
    }
    
    [self.taskViewController switchRoom:self.room.name];
    [self.navigationController pushViewController:self.taskViewController animated:YES];
}

#pragma mark -
#pragma mark - Pull To Resfresh

- (void)refreshTriggered {
    CLAMessage *lastestMessage = [self getRoomMessages].lastObject;
    if (lastestMessage) {
        [self.messageClient getPreviousMessages:lastestMessage.key inRoom:self.room.name];
    } else {
        [self.messageClient loadRooms:@[self.room.name]];
    }
}

- (void)didFinishRefresh {
    [self.tableView finishInfiniteScroll];
}

#pragma mark -
#pragma mark - SlackViewController integration

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [self registerClassForTextView:[MessageTextView class]];
}

#pragma mark - Action Methods

- (void)didLongPressCell:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        MessageTableViewCell *selectedCell = (MessageTableViewCell *)gesture.view;
        self.selectedCellIndexPath = selectedCell.indexPath;
        CLAMessage *selectedMessage = [self getRoomMessages][selectedCell.indexPath.row];
        
        if (selectedMessage) {
            MessageType type = [selectedMessage getType];
            if (type == MessageTypeText) {
                UIActionSheet *actionSheet =
                [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                              destructiveButtonTitle:nil
                                   otherButtonTitles:NSLocalizedString(@"Copy Text", nil), nil];
                
                actionSheet.tag = 2;
                [self.view endEditing:YES];
                [actionSheet showInView:self.view];
            }
        }
    }
}

- (void)didTapCell:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        MessageTableViewCell *selectedCell = (MessageTableViewCell *)gesture.view;
        self.selectedCellIndexPath = selectedCell.indexPath;
        CLAMessage *selectedMessage = [self getRoomMessages][selectedCell.indexPath.row];
        
        if (selectedMessage) {
            MessageType type = [selectedMessage getType];
            if (type == MessageTypeImage) {
                [CLAMediaManager showImage:selectedMessage from:self];
            }
        }
    }
}

- (void)copyTableCellContent:(id)sender {
}

- (void)editCellMessage:(UIGestureRecognizer *)gesture
{
    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
    self.editingMessage = [self getRoomMessages][cell.indexPath.row];
    [self editText:self.editingMessage.content];
    [self.tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Overriden Methods

- (BOOL)ignoreTextInputbarAdjustment
{
    return [super ignoreTextInputbarAdjustment];
}

- (BOOL)forceTextInputbarAdjustmentForResponder:(UIResponder *)responder
{
    if ([responder isKindOfClass:[UIAlertController class]]) {
        return YES;
    }
    
    // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented from another app when using multi-tasking on iPad.
    return SLK_IS_IPAD;
}

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status
{
    // Notifies the view controller that the keyboard changed status.
}

- (void)textWillUpdate
{
    // Notifies the view controller that the text will update.
    
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated
{
    // Notifies the view controller that the text did update.
    
    [super textDidUpdate:animated];
}

- (void)didPressLeftButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    
    actionSheet.tag = 1;
    [self.view endEditing:YES];
    [actionSheet showInView:self.view];
    
    [super didPressLeftButton:sender];
}

- (void)didPressRightButton:(id)sender
{
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
    
    [self.tableView beginUpdates];
    [self sendMessage:[self.textView.text copy]];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [super didPressRightButton:sender];
}

- (NSString *)keyForTextCaching
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (void)didPasteMediaContent:(NSDictionary *)userInfo
{
    // Notifies the view controller when the user has pasted a media (image, video, etc) inside of the text view.
    [super didPasteMediaContent:userInfo];
    
    SLKPastableMediaType mediaType = [userInfo[SLKTextViewPastedItemMediaType] integerValue];
    NSString *contentType = userInfo[SLKTextViewPastedItemContentType];
    id data = userInfo[SLKTextViewPastedItemData];
    
    NSLog(@"%s : %@ (type = %ld) | data : %@",__FUNCTION__, contentType, (unsigned long)mediaType, data);
}

- (void)willRequestUndo
{
    // Notifies the view controller when a user did shake the device to undo the typed text
    
    [super willRequestUndo];
}

- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
    self.editingMessage.content = [self.textView.text copy];
    
    [self.tableView reloadData];
    
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
    
    [super didCancelTextEditing:sender];
}

- (BOOL)canPressRightButton
{
    return [super canPressRightButton];
}

- (BOOL)canShowTypingIndicator
{
#if DEBUG_CUSTOM_TYPING_INDICATOR
    return YES;
#else
    return [super canShowTypingIndicator];
#endif
}

- (void)didChangeAutoCompletionPrefix:(NSString *)prefix andWord:(NSString *)word
{
    self.searchResult = nil;
    
    if ([prefix isEqualToString:@"@"]) {
        RLMResults<CLAUser *> *userResults = nil;
        userResults = [[self.teamUsers objectsWhere:@"name BEGINSWITH[c] %@", word]
                       sortedResultsUsingProperty:@"name" ascending:YES];
        self.searchResult = [CLAUtility getArrayFromRLMResult:userResults];
    }
    else if ([prefix isEqualToString:@"#"] && word.length > 0) {
        RLMResults<CLARoom *> *roomResults = nil;
        RLMArray *rooms = [self.messageClient.dataRepository getCurrentOrDefaultTeam].rooms;
        roomResults = [[rooms objectsWithPredicate:
                        [NSPredicate predicateWithFormat:@"(name BEGINSWITH[c] %@) AND (isDirectRoom == NO)", word]]
                       sortedResultsUsingProperty:@"name" ascending:YES];
        self.searchResult = [CLAUtility getArrayFromRLMResult:roomResults];
    }
    
    BOOL show = (self.searchResult.count > 0);
    [self showAutoCompletionView:show];
}

- (CGFloat)heightForAutoCompletionView
{
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight*self.searchResult.count;
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return [self getRoomMessages].count;
    }
    else {
        return self.searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [self messageCellForRowAtIndexPath:indexPath];
    }
    else {
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    
    if (!cell.textLabel.text) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
        [cell addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell:)];
        [cell addGestureRecognizer:tap];
    }
    
    CLAMessage *message = [self getRoomMessages][indexPath.row];
    cell.message = message;
    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (MessageTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
    if ([self.foundPrefix isEqualToString:@"#"]) {
        CLARoom *room = self.searchResult[indexPath.row];
        cell.room = room;
    }
    else if ([self.foundPrefix isEqualToString:@"@"]) {
        CLAUser *user = self.searchResult[indexPath.row];
        cell.user = user;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        CLAMessage *message = [self getRoomMessages][indexPath.row];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        CGFloat pointSize = [MessageTableViewCell defaultFontSize];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:pointSize],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
        width -= 25.0;
        
        CGRect titleBounds = [message.fromUserName boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [message.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (message.content.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        
        if ([message getType] == MessageTypeText) {
            height += CGRectGetHeight(bodyBounds);
        } else {
            height += kMessageCellImageHeight;
        }
        
        height += 40.0;
        
        if (height < kMessageTableViewCellMinimumHeight) {
            height = kMessageTableViewCellMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMessageTableViewCellMinimumHeight;
    }
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autoCompletionView]) {
        
        NSString *text = nil;
        if ([self.foundPrefix isEqualToString:@"#"]) {
            CLARoom *room = self.searchResult[indexPath.row];
            text = room.name;
        }
        else if ([self.foundPrefix isEqualToString:@"@"]) {
            CLAUser *user = self.searchResult[indexPath.row];
            text = user.name;
        }
        
        [self acceptAutoCompletionWithString:[NSString stringWithFormat:@"%@ ", text] keepPrefix:YES];
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important that if you override this method, to call super.
    [super scrollViewDidScroll:scrollView];
}


#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (BOOL)textView:(SLKTextView *)textView shouldOfferFormattingForSymbol:(NSString *)symbol
{
    if ([symbol isEqualToString:@">"]) {
        
        NSRange selection = textView.selectedRange;
        
        // The Quote formatting only applies new paragraphs
        if (selection.location == 0 && selection.length > 0) {
            return YES;
        }
        
        // or older paragraphs too
        NSString *prevString = [textView.text substringWithRange:NSMakeRange(selection.location-1, 1)];
        
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[prevString characterAtIndex:0]]) {
            return YES;
        }
        
        return NO;
    }
    
    return [super textView:textView shouldOfferFormattingForSymbol:symbol];
}

- (BOOL)textView:(SLKTextView *)textView shouldInsertSuffixForFormattingWithSymbol:(NSString *)symbol prefixRange:(NSRange)prefixRange
{
    if ([symbol isEqualToString:@">"]) {
        return NO;
    }
    
    return [super textView:textView shouldInsertSuffixForFormattingWithSymbol:symbol prefixRange:prefixRange];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.messageClient sendTypingFromUser:self.user.name inRoom:self.room.name];
}

#pragma mark - Lifeterm

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Navigation

- (void)showLeftMenu {
    [[self getSlidingViewController] anchorTopViewToRightAnimated:YES];
}

- (void)showRightMenu {
    [[self getSlidingViewController] anchorTopViewToLeftAnimated:YES];
}


#pragma mark -
#pragma mark - Public Methods

- (void)setActiveRoom:(CLARoom *)room {
    self.room = room;
    [self switchToRoom:room];
}

#pragma mark -
#pragma mark - CLAMessageClientDelegate Methods

- (void)didOpenConnection {
}

- (void)didReceiveConnectionError:(NSError *)error {
    if (error && error.code == -1016) {
        [UserDataManager signOut];
        [[CLAAzureHubPushNotificationService sharedInstance] unregisterDevice];
        [self.messageClient disconnect];
        [self.messageClient.dataRepository deleteData];
        [self switchToSignInView];
    }
}

- (void)switchToSignInView {
    SlidingViewController *slidingViewController = [self getSlidingViewController];
    [slidingViewController clearControllerCache];
    [slidingViewController switchToSignInView];
}

- (void)didConnectionChnageState:(CLAConnectionState)oldState
                        newState:(CLAConnectionState)newState {
    if (newState == CLAConnected) {
        //TODO: when offline, this path is being taken periodically
    }
    else {
    }
}

- (void)didReceiveTeams:(NSInteger)count {
    if (count <= 0) {
        [self sendNoTeamEventNotification];
        return;
    }
    
    [self sendTeamUpdatedEventNotification];
    self.teamUsers = [self.messageClient.dataRepository getCurrentOrDefaultTeam].users;
}

- (void)didReceiveJoinRoom:(NSString *)room andUpdateRoom:(BOOL)update {
    // make sure room switch works both ways, ie, when chat view is active main
    // view or not
    CLARoom *newRoom = [self.messageClient.dataRepository getRoom:room inTeam:[UserDataManager getTeam].key];
    
    if (update != NO) {
        [self sendTeamUpdatedEventNotification];
    }
    
    SlidingViewController *slidingViewController = [self getSlidingViewController];
    
    if (slidingViewController != nil) {
        [slidingViewController switchToRoom:newRoom];
    } else {
        [self switchToRoom:newRoom];
    }
}

- (void)didAddUser:(NSString *)username toRoom:(NSString*)room {
    //TODO: notify used joined room
}

- (void)didReceiveUpdateRoom:(NSString *)room {
    [self sendTeamUpdatedEventNotification];
}

- (void)didReceiveMessageInRoom:(NSString *)room {
    if ([self.room.name isEqualToString: room]) {
        [self.tableView reloadData];
    }
}

- (void)didLoadEarlierMessagesInRoom:(NSString *)room {
    if ([self.room.name isEqualToString: room]) {
        [self.tableView reloadData];
    }
    [self didFinishRefresh];
}

- (void)didReceiveTypingFromUser:(NSString *)user inRoom:(NSString *)room {
    if ([self.room.name isEqualToString: room] && ![self.user.name isEqualToString:user]) {
        [self.typingIndicatorView insertUsername:user];
    }
}

- (void)replaceMessageId:(NSString *)tempMessageId
           withMessageId:(NSString *)serverMessageId {
    [self.messageClient.dataRepository updateMessageKey:tempMessageId withNewKey:serverMessageId];
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            [CLAMediaManager presentPhotoCamera:self canEdit:YES];
        } else if (buttonIndex == 1) {
            [CLAMediaManager presentPhotoLibrary:self canEdit:YES];
        }
    } else if (actionSheet.tag == 2 && self.selectedCellIndexPath) {
        CLAMessage *selectedMessage = [self getRoomMessages][self.selectedCellIndexPath.row];
        self.selectedCellIndexPath = nil;
        
        if (selectedMessage) {
            if (buttonIndex == 0) {
                MessageType type = [selectedMessage getType];
                if (type == MessageTypeText) {
                    [UIPasteboard generalPasteboard].string = selectedMessage.content;
                }
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy_MM_dd_hh_mm_ss"];
    NSString *imageName = [NSString stringWithFormat:@"%@.JPG", [dateFormatter stringFromDate:[NSDate date]]];
    
    UIImage *image = nil;
    image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated: YES completion: ^{
        [self showHud: NSLocalizedString(@"Uploading photo...", nil)];
    }];
    
    __weak __typeof(&*self) weakSelf = self;
    [[CLAWebApiClient sharedInstance] uploadImage:image
                                        imageName:imageName
                                         fromRoom:self.room.name
                                          success:^(id responseObject) {
                                              
                                              [weakSelf hideHud];
                                              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                              [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                          } failure:^(NSError *error) {
                                              [CLANotificationManager showText:NSLocalizedString(@"Oops, upload failed", nil)
                                                             forViewController:weakSelf
                                                                      withType:CLANotificationTypeError];
                                          }];
    
    
}

#pragma mark -
#pragma mark - Private Methods
- (NSArray <CLAMessage *> *)getRoomMessages {
    return [self.messageClient.dataRepository getRoomMessages:self.room.key];
}

- (void)sendMessage:(NSString *)text {
    CLAMessage *message = [[CLAMessage alloc] init];
    message.key = [[NSUUID UUID] UUIDString];
    message.fromUserName = self.user.name;
    message.content = text;
    message.roomKey = self.room.key;
    message.when = [NSDate date];
    message.fromUser = self.user;
    
    [self.messageClient.dataRepository addOrgupdateMessage:message];
    [self.messageClient sendMessage:message inRoom:self.room.name];
}

- (void)switchToRoom:(CLARoom *)room {
    [UserDataManager cacheObject:room.name forKey:kSelectedRoomName];
    self.title = self.room.displayName;
    
    [self.messageClient.dataRepository joinUser:self.user.name
                                         toRoom:self.room.name
                                         inTeam:[UserDataManager getTeam].key];
    [self.tableView reloadData];
}

- (NSIndexPath *)getLasetIndexPath {
    NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex]-1;
    
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}

#pragma mark -
#pragma mark - Notifications
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

- (SlidingViewController *)getSlidingViewController {
    SlidingViewController *slidingViewController = (SlidingViewController *)self.slidingViewController;
    if (!slidingViewController) {
        slidingViewController = [SlidingViewController getAppTopViewController];
    }
    
    return slidingViewController;
}

- (void)showHud {
    [CLANotificationManager
     showText:NSLocalizedString(@"Loading...",nil)
     forViewController:self
     withType:CLANotificationTypeMessage];
}

- (void)showHud:(NSString *)text {
    [CLANotificationManager
     showText:text
     forViewController:self
     withType:CLANotificationTypeMessage];
}

- (void)hideHud {
    [CLANotificationManager dismiss];
}
@end