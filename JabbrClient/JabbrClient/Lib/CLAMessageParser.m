//
//  CLAMessageParser.m
//  Collara
//
//  Created by Sean on 23/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLAMessageParser.h"
#import "SDWebImageManager.h"

@implementation CLAMessageParser

- (void)getMessageData:(NSString *)messageText completionHandler:(void (^)(UIImage *))completion {
    switch ([self getMessageType:messageText]) {
        case MessageTypeImage:
            return [self getPhotoData:messageText completionHandler:completion];
            
        case MessageTypeDocument:
            completion([self getDocumentData:messageText]);
            return;
            
        default:
            return;
    }
}

#pragma - Private Methods

- (void)getPhotoData:(NSString *)messageText completionHandler:(void (^)(UIImage *))completion {
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:messageText]
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                       // progression tracking code
                                                   }
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      completion(image);
                                                  }];
}

- (UIImage *)getDocumentData:(NSString *)messageText {
    return [Constants documentIconLarge];
}

- (MessageType)getMessageType:(NSString *)text {
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
@end
