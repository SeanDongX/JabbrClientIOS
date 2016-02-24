//
//  MessageTableViewCell.m
//  Messenger
//
//  Created by Ignacio Romero Zurbuchen on 9/1/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "SLKTextView+SLKAdditions.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "DateTools.h"
#import "CLARoom.h"
#import "Constants.h"
#import "CLAMessageParser.h"

@interface MessageTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *imageContentView;

@property (nonatomic, strong) CLAMessageParser *messageParser;

@end

@implementation MessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.messageParser = [[CLAMessageParser alloc] init];
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews
{
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.imageContentView];
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[MessageTableViewCell defaultFontSize]];
    self.titleLabel.text = @"";
    
    //[self setContraints];
}

- (void)setContraints:(BOOL)isTextMessage {
    
    NSDictionary *views = @{@"avatarView": self.avatarView,
                            @"titleLabel": self.titleLabel,
                            @"bodyLabel": self.bodyLabel,
                            @"imageContentView": self.imageContentView};
    
    NSDictionary *metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
                              @"padding": @15,
                              @"right": @10,
                              @"left": @5};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[avatarView(<=tumbSize)]-right-[titleLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[avatarView(<=tumbSize)]-right-[bodyLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[avatarView(<=tumbSize)]-right-[imageContentView(>=0,<=80)]-right-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[avatarView(<=tumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    
    
    if ([self.reuseIdentifier isEqualToString:MessengerCellIdentifier]) {
        if (isTextMessage == NO) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-left-[imageContentView(80)]-left-|" options:0 metrics:metrics views:views]];
        } else {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[titleLabel(20)]-left-[bodyLabel(>=0@999)]-left-|" options:0 metrics:metrics views:views]];
        }
    }
    else {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:metrics views:views]];
    }
}

#pragma mark - Setters

- (void)setRoom:(CLARoom *)room {
    if (room) {
        self.titleLabel.text = [NSString stringWithFormat:@"#%@", room.name];
        self.avatarView.image = [JSQMessagesAvatarImageFactory
                                 avatarImageWithUserInitials:@"#"
                                 backgroundColor:[Constants highlightColor]
                                 textColor:[UIColor whiteColor]
                                 font:[UIFont systemFontOfSize:13.0f]
                                 diameter:30.0f].avatarImage;
    }
}

- (void)setUser:(CLAUser *)user {
    if (user) {
        self.titleLabel.text = [NSString stringWithFormat:@"@%@", user.name];
        
        if (user.initials) {
            self.avatarView.image = [JSQMessagesAvatarImageFactory
                                     avatarImageWithUserInitials:user.initials
                                     backgroundColor: [user getUIColor]
                                     textColor:[UIColor whiteColor]
                                     font:[UIFont systemFontOfSize:13.0f]
                                     diameter:30.0f].avatarImage;
        }
    }
}

- (void)setMessage:(CLAMessage *)message {
    if (message) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@ - %@", message.fromUserName, message.when.timeAgoSinceNow];
        
        if (message.fromUser && message.fromUser.initials) {
            self.avatarView.image = [JSQMessagesAvatarImageFactory
                                     avatarImageWithUserInitials:message.fromUser.initials
                                     backgroundColor: [message.fromUser getUIColor]
                                     textColor:[UIColor whiteColor]
                                     font:[UIFont systemFontOfSize:13.0f]
                                     diameter:30.0f].avatarImage;
        }
        
        MessageType messageType = [self.messageParser getMessageType:message.content];
        if (messageType == MessageTypeImage || messageType == MessageTypeDocument) {
            [self setContraints:NO];
            
            UIImageView *imageView = self.imageContentView;
            [self.messageParser getMessageData: message.content completionHandler:^(UIImage *image) {
                imageView.image = image;
            }];
        }
        else {
            [self setContraints:YES];
            
            self.bodyLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell defaultFontSize]];
            self.bodyLabel.text = message.content;
        }
    }
}

#pragma mark - Getters

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:[MessageTableViewCell defaultFontSize]];
    }
    return _titleLabel;
}

- (UILabel *)bodyLabel
{
    if (!_bodyLabel) {
        _bodyLabel = [UILabel new];
        _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyLabel.backgroundColor = [UIColor clearColor];
        _bodyLabel.userInteractionEnabled = NO;
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.textColor = [UIColor darkGrayColor];
        _bodyLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell defaultFontSize]];
    }
    return _bodyLabel;
}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.userInteractionEnabled = NO;
        _avatarView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        _avatarView.layer.cornerRadius = kMessageTableViewCellAvatarHeight/2.0;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UIImageView *)imageContentView
{
    if (!_imageContentView) {
        _imageContentView = [UIImageView new];
        _imageContentView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageContentView.userInteractionEnabled = YES;
        _imageContentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _imageContentView.layer.cornerRadius = 10;
        _imageContentView.layer.masksToBounds = YES;
    }
    return _imageContentView;
}

+ (CGFloat)defaultFontSize
{
    CGFloat pointSize = 16.0;
    
    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
    pointSize += [SLKTextView pointSizeDifferenceForCategory:contentSizeCategory];
    
    return pointSize;
}

@end
