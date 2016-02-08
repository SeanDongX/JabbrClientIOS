//
//  CLADisplayMessageFactory.m
//  Collara
//
//  Created by Sean on 04/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLADisplayMessageFactory.h"

#import "JSQPhotoMediaItem.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation CLADisplayMessageFactory

- (CLAMessageViewModel*)create:(CLAMessageViewModel *)message completionHandler:(void (^)())completion {
    id<JSQMessageMediaData> mediaData = [self getMessageData:message.text
                                           completionHandler:completion];
    if (mediaData == nil) {
        return message;
    }
    
    return [[CLAMessageViewModel alloc]
            initWithOId:message.oId
            SenderId:message.senderId
            senderDisplayName:message.senderDisplayName
            date:message.date
            media:mediaData
            text:message.text];
}

+ (MessageType)getMessageType:(NSString *)text {
    NSPredicate *textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"https?:\\/\\/.*\\.(?:png|jpg)"];
    
    if ([textTest evaluateWithObject:[text lowercaseString]]) {
        return MessageTypeImage;
    }
    
    textTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"https?:\\/\\/.*\\.(?:txt|md|js|doc|docx|xsl|xslx|ppt|pptx)"];
    
    if ([textTest evaluateWithObject:[text lowercaseString]]) {
        return MessageTypeDocument;
    }
    
    return MessageTypeText;
}

#pragma mark -
#pragma mark - Private Methods
- (id<JSQMessageMediaData>)getMessageData:(NSString *)messageText completionHandler:(void (^)())completion {
    switch ([CLADisplayMessageFactory getMessageType:messageText]) {
        case MessageTypeImage:
            return [self getPhotoData:messageText completionHandler:completion];
            
        case MessageTypeDocument:
            completion();
            return [self getDocumentData:messageText];
            
        default:
            return nil;
    }
}

- (id<JSQMessageMediaData>)getPhotoData:(NSString *)messageText completionHandler:(void (^)())completion {
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

- (id<JSQMessageMediaData>)getDocumentData:(NSString *)messageText {
    return [[JSQPhotoMediaItem alloc] initWithImage: [Constants documentIconLarge]];
}
@end
