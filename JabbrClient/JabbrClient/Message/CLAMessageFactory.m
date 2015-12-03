//
//  CLAMessageFactory.m
//  Collara
//
//  Created by Sean on 02/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLAMessageFactory.h"
#import "Constants.h"
#import "JSQPhotoMediaItem.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation CLAMessageFactory

#pragma mark -
#pragma mark - Public Methods

- (CLAMessage *)create:(NSDictionary *)messageDictionary {
    NSString *userName = @"?";
    NSString *userInitials = @"?";
    
    NSDictionary *userData = [messageDictionary objectForKey:@"User"];
    
    NSString *dateString = [messageDictionary objectForKey:@"When"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    
    if (userData) {
        if ([userData objectForKey:@"Name"]) {
            userName = [[userData objectForKey:@"Name"] lowercaseString];
            userInitials = userName;
        }
        
        if ([userData objectForKey:@"Initials"]) {
            userInitials = [userData objectForKey:@"Initials"];
        }
    }
    
    NSString *oId = [messageDictionary objectForKey:@"Id"];
    NSString *text = [messageDictionary objectForKey:@"Content"];
    
    id mediaData = [self getMessageData:text];
    
    if (mediaData != nil) {
        return [[CLAMessage alloc]
                initWithOId:oId
                SenderId:userName
                senderDisplayName:userInitials
                date:date
                media:mediaData];
    }
    
    return [[CLAMessage alloc]
            initWithOId:oId
            SenderId:userName
            senderDisplayName:userInitials
            date:date
            text:text];
}

#pragma mark -
#pragma mark - Private Methods

- (MessageType)getMessageType:(NSString *)text {
    NSPredicate *textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"https?:\\/\\/.*\\.(?:png|jpg)"];
    
    if ([textTest evaluateWithObject:text]) {
        return MessageTypeImage;
    }
    
    return MessageTypeText;
}

- (id<JSQMessageMediaData>)getMessageData:(NSString *)messageText {
    switch ([self getMessageType:messageText]) {
        case MessageTypeImage:
            return [self getImage:messageText];
        default:
            return nil;
    }
}

- (id<JSQMessageMediaData>)getImage:(NSString *)messageText {
    JSQPhotoMediaItem *mediaData = [[JSQPhotoMediaItem alloc] initWithImage:nil];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:messageText]
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                       // progression tracking code
                                                   }
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (image) {
                                                          mediaData.image = image;
                                                      }
                                                  }];
    
    return mediaData;
}

@end
