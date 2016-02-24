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
#import "Masonry.h"

@interface MessageTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

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
    [self.contentView addSubview:self.timestampLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.imageContentView];
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setContraints {
    NSNumber *horizontalmargin = @10;
    NSNumber *verticalmargin = @10;
    NSNumber *timestampWith = @140;
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(verticalmargin.floatValue);
        make.left.equalTo(self.contentView.mas_left).with.offset(horizontalmargin.floatValue);
        make.width.equalTo(@(kMessageTableViewCellAvatarHeight));
        make.height.equalTo(@(kMessageTableViewCellAvatarHeight));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(verticalmargin.floatValue);
        make.left.equalTo(self.avatarView.mas_right).with.offset(horizontalmargin.floatValue);
        make.right.equalTo(self.contentView.mas_right).with.offset(-1 * timestampWith.floatValue);
        make.height.equalTo(@20);
    }];
    
    [self.timestampLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(verticalmargin.floatValue);
        make.right.equalTo(self.contentView.mas_right).with.offset(-1 * horizontalmargin.floatValue);
        make.width.equalTo(@(timestampWith.floatValue - 20));
        make.height.equalTo(@20);
    }];
    
    [self.bodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(verticalmargin.floatValue);
        make.left.equalTo(self.avatarView.mas_right).with.offset(horizontalmargin.floatValue);
        make.right.equalTo(self.contentView.mas_right).with.offset(-1 *horizontalmargin.floatValue);
    }];
    
    [self.imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(verticalmargin.floatValue);
        make.left.equalTo(self.avatarView.mas_right).with.offset(horizontalmargin.floatValue);
        make.width.equalTo(@(kMessageCellImageWidth));
        make.height.equalTo(@(kMessageCellImageHeight));
    }];
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
        
        if (message.fromUser && message.fromUser.initials) {
            self.avatarView.image = [JSQMessagesAvatarImageFactory
                                     avatarImageWithUserInitials:message.fromUser.initials
                                     backgroundColor: [message.fromUser getUIColor]
                                     textColor:[UIColor whiteColor]
                                     font:[UIFont systemFontOfSize:13.0f]
                                     diameter:30.0f].avatarImage;
        }
        
        self.titleLabel.text = message.fromUserName;
        [self setTimestamp:message];
        [self setContent:message];
    }
}

- (void)setTimestamp:(CLAMessage *)message {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    if (message.when.daysAgo > 1) {
        [formatter setDateStyle:NSDateFormatterShortStyle];
    } else {
        [formatter setDateStyle:NSDateFormatterNoStyle];
    }
    
    self.timestampLabel.text = [formatter stringFromDate:message.when];
}

- (void)setContent:(CLAMessage *)message {
    MessageType messageType = [message getType];
    if (messageType == MessageTypeImage || messageType == MessageTypeDocument) {
        
        self.bodyLabel.hidden = YES;
        self.imageContentView.hidden = NO;
        
        [self setContraints];
        self.bodyLabel.text = @"";
        self.imageContentView.image = nil;
        [self.messageParser getMessageData:message completionHandler:^(UIImage *image) {
            self.imageContentView.image = image;
        }];
    }
    else {
        
        self.bodyLabel.hidden = NO;
        self.imageContentView.hidden = YES;
        
        [self setContraints];
        
        self.bodyLabel.text = message.content;
        self.imageContentView.image = nil;
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
        _titleLabel.textColor = [Constants mainThemeContrastColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:[MessageTableViewCell defaultFontSize]];
    }
    return _titleLabel;
}

- (UILabel *)timestampLabel
{
    if (!_timestampLabel) {
        _timestampLabel = [UILabel new];
        _timestampLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timestampLabel.backgroundColor = [UIColor clearColor];
        _timestampLabel.userInteractionEnabled = NO;
        _timestampLabel.numberOfLines = 0;
        _timestampLabel.textAlignment = NSTextAlignmentRight;
        _timestampLabel.textColor = [Constants mutedTextColor];
        _timestampLabel.font = [UIFont systemFontOfSize:[MessageTableViewCell defaultFontSize] - 4 ];
    }
    return _timestampLabel;
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
