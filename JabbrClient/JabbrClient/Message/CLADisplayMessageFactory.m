//
//  CLADisplayMessageFactory.m
//  Collara
//
//  Created by Sean on 04/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLADisplayMessageFactory.h"

#import "Constants.h"
#import "JSQPhotoMediaItem.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation CLADisplayMessageFactory

- (CLAMessage*)create:(CLAMessage *)message completionHandler:(void (^)())completion {
    id<JSQMessageMediaData> mediaData = [self getMessageData:message.text
                                           completionHandler:completion];
    if (mediaData == nil) {
        return message;
    }
    
    return [[CLAMessage alloc]
            initWithOId:message.oId
            SenderId:message.senderId
            senderDisplayName:message.senderDisplayName
            date:message.date
            media:mediaData];
}

#pragma mark -
#pragma mark - Private Methods

- (MessageType)getMessageType:(NSString *)text {
    NSPredicate *textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"https?:\\/\\/.*\\.(?:png|jpg)"];
    
    if ([textTest evaluateWithObject:[text lowercaseString]]) {
        return MessageTypeImage;
    }
    
    return MessageTypeText;
}

- (id<JSQMessageMediaData>)getMessageData:(NSString *)messageText completionHandler:(void (^)())completion {
    switch ([self getMessageType:messageText]) {
        case MessageTypeImage:
            return [self getImage:messageText completionHandler:completion];
        default:
            return nil;
    }
}

- (id<JSQMessageMediaData>)getImage:(NSString *)messageText completionHandler:(void (^)())completion {
    JSQPhotoMediaItem *mediaData = [[JSQPhotoMediaItem alloc] initWithImage:nil];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:messageText]
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                       // progression tracking code
                                                   }
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (image) {
                                                          [mediaData setImage:image];
                                                          completion();
                                                      }
                                                  }];
    
    return mediaData;
}

@end
